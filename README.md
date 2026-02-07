run
ubah docker compose 
volumes:
      - .:/app
      - {directory movie}:/media/film:ro
docker compose down && docker compose build --no-cache && docker compose up -d