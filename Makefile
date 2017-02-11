build:
	docker build -t pairbox .

run:
	docker run --name pairbox -d --shm-size=256m \
		-p 4444:22 -p 2000-2010:2000-2010 \
		-v pairbox-home:/home/pairbox -v pairbox-home-src:/home/pairbox/src \
		mebubo/pairbox

kill:
	-docker kill pairbox
	-docker rm pairbox

host:
	ansible-playbook -i docker-host, docker-host.yml
