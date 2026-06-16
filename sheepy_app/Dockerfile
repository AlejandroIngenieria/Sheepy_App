FROM ubuntu:20.04 AS build-env

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias para Flutter
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Descargar Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Activar web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

WORKDIR /app
COPY . .

# Obtener dependencias y construir
RUN flutter pub get
RUN flutter build web --release

# Etapa de servidor con Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
