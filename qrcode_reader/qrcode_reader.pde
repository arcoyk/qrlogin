import processing.video.*;
import com.google.zxing.*;
import java.awt.image.BufferedImage;
import java.io.FileWriter;
import java.io.*;
import ddf.minim.*;
import gab.opencv.*;
import java.awt.Rectangle;

OpenCV opencv;
Minim minim;
AudioSample ping;
Capture cam;
com.google.zxing.Reader reader = new com.google.zxing.qrcode.QRCodeReader();

PImage cover;
String lastISBNAcquired = "";
String msg = "Show QR code";
String last = "";
PrintWriter pw;
PImage recent_face;

void setup() {
  size(950, 540);
  String[] cams = Capture.list();
  for (String cam : cams) {
    println(cam);
  }
  cam = new Capture(this, cams[3]);
  cam.start();
  minim = new Minim(this);
  ping = minim.loadSample("pingpong.mp3", 512);
  textSize(20);
  noStroke();
}


void draw() {
  if (cam.available() == true) {
    cam.read();
    image(cam, 0,0);
    opencv = new OpenCV(this, cam);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    // opencv.loadCascade(OpenCV.CASCADE_PEDESTRIAN);
    Rectangle[] faces = opencv.detect();
    if (recent_face != null) {
      image(recent_face, 0, 40);
    }
    if (faces.length > 0) {
      recent_face = get(faces[0].x, faces[0].y, faces[0].width, faces[0].height);
    }
    try {
       LuminanceSource source = new BufferedImageLuminanceSource((BufferedImage)cam.getImage());
       BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));       
       Result result = reader.decode(bitmap);
       if (result.getText() != null && !result.getText().equals(last)) {
          println(result.getText());
          ResultPoint[] points = result.getResultPoints();
          fill(255, 0, 0);
          ellipse(points[0].getX(), points[0].getY(), 50, 50);
          fill(0, 0, 255);
          ellipse(points[1].getX(), points[1].getY(), 50, 50);
          fill(0, 255, 0);
          ellipse(points[2].getX(), points[2].getY(), 50, 50);
          ping.trigger();
          msg = result.getText();
          last = msg;
          appendText(msg + "," + year() + "," + month() + "," + day() + "," + hour() + "," + minute() + "," + second() + "\n");
          recent_face.save("/users/kitayui/desktop/imgs/" + msg + "_" + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".png");
       }
    } catch (Exception e) {
    }
  }
  draw_text(msg);
}

void draw_text(String str) {
  fill(255);
  rect(0, 0, width, 40);
  fill(0);
  text(str, 10, 30);
}

void keyPressed() {
  int i = 0;
  int m = 1 / i;
}

void appendText(String text) {
    try {
    File file =new File("/users/kitayui/desktop/log.txt");
    if (!file.exists()) {
      file.createNewFile();
    }
    FileWriter fw = new FileWriter(file, true);
    BufferedWriter bw = new BufferedWriter(fw);
    PrintWriter pw = new PrintWriter(bw);
    pw.write(text);
    pw.close();
  } catch(IOException e) {
  }
}
