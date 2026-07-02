# =====================
# Variables
# =====================
SYNAPSE_IMAGE = matrixdotorg/synapse:v1.141.0
SERVER_NAME = localhost
DATA_VOLUME = chat-admin-dashboard_chat_data

# =====================
# Phony targets
# =====================
.PHONY: all init up down restart logs synapse-gen config register-admin clean

# =====================
# Full setup flow
# =====================
all: init up register-admin

# =====================
# 1. Initialize system
# =====================
init: synapse-gen config

# =====================
# 2. Start docker services
# =====================
up:
	docker compose up -d --build

# =====================
# 3. Stop services
# =====================
down:
	docker compose down

# =====================
# Restart services
# =====================
restart:
	@make down
	@make up

# =====================
# Logs
# =====================
logs:
	docker compose logs -f

# =====================
# Synapse key generation
# =====================
synapse-gen:
	docker run --rm \
		-v $(DATA_VOLUME):/data \
		-e SYNAPSE_SERVER_NAME=$(SERVER_NAME) \
		-e SYNAPSE_REPORT_STATS=no \
		$(SYNAPSE_IMAGE) generate

# =====================
# Config overwrite
# =====================
config:
	@echo "Writing homeserver.yaml..."
	@docker run --rm -i \
		-v $(DATA_VOLUME):/data \
		alpine sh -c "cat > /data/homeserver.yaml" < homeserver.tmpl

# =====================
# Register admin user
# =====================
register-admin:
	@echo "Registering admin user..."
	docker exec -it chat \
		register_new_matrix_user \
		-c /data/homeserver.yaml \
		http://localhost:8008

# =====================
# Cleanup (dangerous)
# =====================
clean:
	docker compose down -v --remove-orphans