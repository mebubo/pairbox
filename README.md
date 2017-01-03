Start Xvnc:

    Xtigervnc -localhost -geometry 1920x1080 -SecurityTypes None :1

ssh config:

    Host pairbox
         User pairbox
         Hostname <ip>
         Port 4444
         LocalForward 5901 localhost:5901

vnc viewer:

    vncviewer localhost:1

Copy the volume to HOST:

    docker run --rm -v pairbox-home:/from debian:unstable tar -C /from -cz . | ssh HOST docker run --rm -i -v pairbox-home:/to debian:unstable tar -C /to -xzv
