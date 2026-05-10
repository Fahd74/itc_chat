"""Supabase JWT Authentication middleware for FastAPI."""

from fastapi import Request, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from app.config import settings


security = HTTPBearer(auto_error=False)


def verify_supabase_token(token: str) -> dict:
    """
    Verify a Supabase JWT token and return the payload.
    
    In development mode (no JWT secret configured), 
    we skip verification and return a dummy user.
    """
    # Development mode — skip verification if no secret is set
    if not settings.SUPABASE_JWT_SECRET or settings.SUPABASE_JWT_SECRET == "your_supabase_jwt_secret":
        return {"sub": "dev-user-id", "email": "dev@local.test"}

    try:
        payload = jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience="authenticated",
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    FastAPI dependency that extracts and verifies the user from the
    Authorization header. Returns user payload dict.
    
    If no credentials provided, allows access in dev mode.
    """
    if credentials is None:
        # Dev mode: allow unauthenticated access
        if not settings.SUPABASE_JWT_SECRET or settings.SUPABASE_JWT_SECRET == "your_supabase_jwt_secret":
            return {"sub": "dev-user-id", "email": "dev@local.test"}
        raise HTTPException(status_code=401, detail="Authorization header missing")

    return verify_supabase_token(credentials.credentials)
