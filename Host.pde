import processing.net.Client;
import processing.net.Server;

import java.util.Random;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

PApplet myApplet = this;

class Host {
    Server myServer;
    Client myClient;

    URL gameURL;
    URLConnection myConn;

    String gameRoom;
    boolean pinged = false;

    Host() {
        genGameRoom();

        try {
            gameURL = new URL(String.format("http://localhost:20793/%s/admin", gameRoom));
        }
        catch (IOException ioe) {
            ioe.printStackTrace();
        } 
    }

    void startServer() {
        myServer = new Server(myApplet, 20793);
    }

    void readData() {
        myServer.write("HEllo there!\n");
        // myClient = myServer.available();
        // if (myClient != null) process();
    }

    void ping() {
        if (!pinged) {
            try {
                myConn = gameURL.openConnection();
                myConn.connect();

                System.out.println(gameURL.getPath());
                System.out.println("What, no errors?");

                BufferedReader in = new BufferedReader(new InputStreamReader(myConn.getInputStream()));
                String inputLine;
                while ((inputLine = in.readLine()) != null) 
                    System.out.println(inputLine);
                in.close();

                pinged = true;
            }
            catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    void process() {
        // System.out.println("Connection");
    }

    /*
        Generates the code which will be used for the game room.
    */
    void genGameRoom() {
        char[] chars = "abcdefghijklmnopqrstuvwxyz".toCharArray();
        StringBuilder code = new StringBuilder();
        Random random = new Random();

        for (int i = 0; i < 5; i++) code.append((char) (random.nextInt(26) + 65));
        
        gameRoom = code.toString();
        System.out.println(gameRoom);
    }
}