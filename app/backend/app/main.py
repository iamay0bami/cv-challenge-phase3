from prometheus_fastapi_instrumentator import Instrumentator
import sentry_sdk
from fastapi import FastAPI
from fastapi.routing import APIRoute
from starlette.middleware.cors import CORSMiddleware

from app.api.main import api_router
from app.core.config import settings


# Replace your custom_generate_unique_id with this
def custom_generate_unique_id(route: APIRoute) -> str:
    # some routes (added by libs) may not define tags; fall back safely
    tag = route.tags[0] if getattr(route, "tags", None) else "no-tag"
    name = getattr(route, "name", None) or "route"
    return f"{tag}-{name}"




if settings.SENTRY_DSN and settings.ENVIRONMENT != "local":
    sentry_sdk.init(dsn=str(settings.SENTRY_DSN), enable_tracing=True)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    generate_unique_id_function=custom_generate_unique_id,
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[
            str(origin).strip("/") for origin in settings.BACKEND_CORS_ORIGINS
        ],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Add API routers
app.include_router(api_router, prefix=settings.API_V1_STR)

# 🚀 Add Prometheus metrics endpoint
Instrumentator().instrument(app).expose(app, endpoint="/metrics")
