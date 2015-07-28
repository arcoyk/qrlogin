import processing.video.*;
import com.google.zxing.*;
import java.awt.image.BufferedImage;
import ddf.minim.*;

Minim minim;
AudioSample ping;

Capture cam;
com.google.zxing.Reader reader = new com.google.zxing.qrcode.QRCodeReader();

PImage cover;
String lastISBNAcquired = "";

String msg = "Show QR code";
String last = "";

PrintWriter output;

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
  
  output = createBufferedWriter("log.txt");
  
  textSize(20);
  noStroke();
}

PrintWriter createBufferedWriter(String file) {
  String[] lines = loadStrings(file);
  PrintWriter output = createWriter(file + "2.txt");
  for (int i = 0; i < lines.length; i++) {
    output.println(lines[i]);
    output.flush();
  }
  return output;
}
  

void draw() {
  if (cam.available() == true) {
    cam.read();
    image(cam, 0,0);
    try {
       // Now test to see if it has a QR code embedded in it
       LuminanceSource source = new BufferedImageLuminanceSource((BufferedImage)cam.getImage());
       BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));       
       Result result = reader.decode(bitmap);
       //Once we get the results, we can do some display
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
          output.println(msg + "," + year() + "," + month() + "," + day() + "," + hour() + "," + minute() + "," + second());
          output.flush();
       }
    } catch (Exception e) {
//         println(e.toString()); 
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
