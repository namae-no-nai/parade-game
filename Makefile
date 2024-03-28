start:
	docker-compose up -d && \
	docker-compose exec -d web rails tailwindcss:watch && \
	docker attach parade-game-web
