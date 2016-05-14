build:
	docker build -t pairbox .

run:
	docker run --name pairbox -d -p 4444:22 -p 2000-2010:2000-2010 -v pairbox-home:/home/pairbox pairbox 

kill:
	-docker kill pairbox
	-docker rm pairbox
