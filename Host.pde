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
    
    String baseURL = "http://localhost:20793";

    String gameRoom;
    boolean pinged = false;

    Host() {
        genGameRoom();

        try {
            gameURL = new URL(String.format("%s/admin", baseURL));
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

    /*
    * Creates the room to play the game
    */
    void ping() {
        if (!pinged) {
            try {
                myConn = gameURL.openConnection();
                myConn.connect();

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
        StringBuilder code = new StringBuilder();
        Random random = new Random();

        for (int i = 0; i < 5; i++) code.append((char) (random.nextInt(26) + 65));
        
        gameRoom = code.toString();
        baseURL += "/" + gameRoom;
    }

    ArrayList<String> sendRequest(String endpoint) {
        ArrayList<String> response = new ArrayList<String>();

        try {
            URL reqURL = new URL(String.format("%s/%s", baseURL, endpoint));
            URLConnection reqConn = reqURL.openConnection();

            BufferedReader in = new BufferedReader(new InputStreamReader(reqConn.getInputStream()));
            String inputLine;
            while ((inputLine = in.readLine()) != null) 
                response.add(inputLine);
            in.close();
        } 
        catch (IOException ioe) {
            ioe.printStackTrace();
            return null;
        }

        return response;
    }
}