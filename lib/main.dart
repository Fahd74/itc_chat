import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:itc_chat/core/config/app_theme.dart';
import 'package:itc_chat/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_cubit.dart';
import 'package:itc_chat/features/auth/ui/cubit/auth_state.dart';
import 'package:itc_chat/features/chat/data/datasources/chat_history_datasource.dart';
import 'package:itc_chat/features/chat/ui/cubit/chat_history_cubit.dart';
import 'package:itc_chat/features/onboarding/ui/screens/onbo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final authRepo = AuthRepositoryImpl(supabaseClient: supabaseClient);
    final chatHistoryDs = ChatHistoryDataSource(client: supabaseClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepo)),
        BlocProvider(create: (_) => ChatHistoryCubit(chatHistoryDs)),
      ],
      child: _AppWithAuthListener(
        child: MaterialApp(
          title: 'Assist AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Onboarding(),
        ),
      ),
    );
  }
}

/// Listens to auth state changes and loads conversations when
/// the user is authenticated.
class _AppWithAuthListener extends StatelessWidget {
  final Widget child;
  const _AppWithAuthListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // User just logged in — load their conversations
          context.read<ChatHistoryCubit>().loadConversations();
        }
      },
      child: child,
    );
  }
}

