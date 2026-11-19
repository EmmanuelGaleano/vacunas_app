# =============================================================================
# Dockerfile - Vacunas App (versión web)
#
# La app se compila para web en el computador, con el mismo Flutter que se
# usa para desarrollar, y este contenedor solo la sirve con nginx
# (un servidor web liviano, la imagen pesa unos 20 MB).
#
# ANTES de construir la imagen hay que compilar la app:
#   flutter build web --release --dart-define=API_URL=mismo-origen
#
# API_URL=mismo-origen le dice a la app (lib/config/api_config.dart) que
# llame a la API en la misma dirección de la página; nginx la reenvía.
#
# Luego:
#   docker compose up -d --build
# =============================================================================

FROM nginx:alpine

# Configuración propia de nginx (rutas de GoRouter + proxy hacia la API).
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Archivos de la app ya compilada (los genera "flutter build web").
COPY build/web /usr/share/nginx/html

EXPOSE 80
