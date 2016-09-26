Start Xvnc:

    Xvnc -localhost -geometry 1920x1080 -SecurityTypes None :1

ssh config:

    Host pairbox
         User pairbox
         Hostname <ip>
         Port 4444
         LocalForward 5901 localhost:5901

vnc viewer:

    vncviewer localhost:1
