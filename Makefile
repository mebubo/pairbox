build:
	docker build -t pairbox .

run:
	docker run --name pairbox -d --shm-size=256m \
		-p 4444:22 -p 2000-2010:2000-2010 \
		-v pairbox-home:/home/pairbox -v pairbox-home-src:/home/pairbox/src \
		mebubo/pairbox

run-local:
	docker run --name pairbox -d --shm-size=256m \
		-p 127.0.0.1:4444:22 \
		-p 127.0.0.1:2000-2010:2000-2010 \
		-v pairbox-home:/home/pairbox \
		-v /home/meb/src:/home/pairbox/src \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--device /dev/dri \
		pairbox

kill:
	-docker kill pairbox
	-docker rm pairbox

host:
	ansible-playbook -i docker-host, docker-host.yml
