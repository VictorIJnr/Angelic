import processing.net.Client;
import processing.net.Server;

import java.util.Random;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.HttpURLConnection;
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

    //Button used to allocate roles to players
    ActionButton roleAlloc;

    Host() {
        genGameRoom();
        roleAlloc = new ActionButton(Action.START_GAME, new PVector(width / 2, height * 0.75));

        try {
            gameURL = new URL(String.format("%s/admin", baseURL));
        }
        catch (IOException ioe) {
            ioe.printStackTrace();
        } 
    }

    void draw() {
        roleAlloc.draw();
    }

    void mouseClick() {
        roleAlloc.mouseClicked();
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
                System.out.println("Okay, please give me an error...");
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

    /*
        Allows for sending a post request to an endpoint on the server.
    */
    ArrayList<String> postData(String endpoint, JSONObject data) {
        ArrayList<String> response = new ArrayList<String>();
        try {
            StringBuilder bob = new StringBuilder();
            URL postURL = new URL(String.format("%s/%s", baseURL, endpoint));
            HttpURLConnection post = (HttpURLConnection) postURL.openConnection();
            post.setRequestMethod("POST");
            post.setRequestProperty("Content-Type", "application/json");
            post.setDoOutput(true);

            System.out.println("Sent data: " + data.toString());
            PrintWriter postWriter = new PrintWriter(post.getOutputStream());
            postWriter.write(data.toString());
            postWriter.close();

            String inputLine;
            BufferedReader in = new BufferedReader(new InputStreamReader(post.getInputStream()));
            while ((inputLine = in.readLine()) != null) {
                response.add(inputLine);
                bob.append(inputLine);
            }
            System.out.println("Received response." + millis());
            in.close();
            System.out.printf("Closed Stream.\n%d\nRespons:\n\t%s\n", millis(), bob.toString());
        }
        catch(IOException ioe) {
            ioe.printStackTrace();
            return null;
        }
        System.out.println("Returning response.");
        return response;
    }

    String getGameURL() {
        return baseURL;
    }
}