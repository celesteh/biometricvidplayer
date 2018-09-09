//import  com.bitalino.comm.*;
import java.util.Vector;
//import javax.bluetooth.*;
import processing.serial.*;
import java.nio.channels.ClosedChannelException;

/*

The user runing this class must be a memvber of the group dialup.
Connect to the bitalino using the bluetooth GUI for your system
Make a note of what /dev port it attached to

from https://makezine.com/projects/use-bitalino-graph-biosignals-play-pong/
edwindertien.nl
*/

public class Bitalino {

  int PORTNUMBER;
  Serial port;
  int lines;
  int value[];
  char buffer[];
  int counter;
  PApplet parent;


  public Bitalino(PApplet app) {

    PORTNUMBER = 0;
    lines = 6;
    value= new int[lines];
    buffer = new char[8];
    counter = 0;
    parent = app;
  }

  public Bitalino(PApplet app, int portnum) {
    this(app);
    this.setPort(portnum);
  }

  public Bitalino(PApplet app, int portnum, int rate) {
    this(app);
    this.setPort(portnum, rate);
  }


  String[] getPorts () {

    String[] ports;
    int len;

    len = Serial.list().length;

    ports = new String[len];

    println("Available serial ports:");
    for (int i = 0; i<len; i++) {
      print("[" + i + "] ");
      println(Serial.list()[i]);
      ports[i] = Serial.list()[i];
    }

    return ports;
  }

  void setPort(int num, int rate) {
    PORTNUMBER = num;

    port = new Serial(parent, Serial.list()[PORTNUMBER], 115200);
    this.setRate(rate);
  }

  void setPort(int num) {

    this.setPort(num, 1);
  }

  void setRate( int rate) {

    int cmd = rate;  // 0 for 1 sample/sec, 1 for 10 samples/sec, 2 for 100 samples/sec, 3 for 1000 samples/sec
    port.write((cmd << 6) | 0x03); // 10 samples/sec
    delay(50);
    int channelmask = 0x3F;
    port.write(channelmask<<2 | 0x01);
  }

  int[] read() throws BitalinoUnreadyException {

    if (port.available () <= 0) {
      throw new BitalinoUnreadyException();
    }

    while (port.available () > 0) {
      serialEvent(port.read()); // read data
    }

    return value;
  }

  void serialEvent(int serialdata) {
    if (counter<7) {
      print(serialdata);
      print(',');
      buffer[counter] = (char)serialdata;
      counter++;
    } else {
      print(serialdata);
      buffer[counter] = (char)serialdata;
      counter = 0;
      // check CRC
      int crc = buffer[7] & 0x0F;
      buffer[7] &= 0xF0;  // clear CRC bits in frame
      int x = 0;
      for (int i = 0; i < 8; i++) {
        for (int bit = 7; bit >= 0; bit--) {
          x <<= 1;
          if ((x & 0x10) > 0)  x = x ^ 0x03;
          x ^= ((buffer[i] >> bit) & 0x01);
        }
      }
      if (crc != (x & 0x0F))  println(" - crc mismatch");
      else {
        println(" - crc ok");
        value[0] = ((buffer[6] & 0x0F) << 6) | (buffer[5] >> 2);
        value[1] = ((buffer[5] & 0x03) << 8) | (buffer[4]);
        value[2] = ((buffer[3]       ) << 2) | (buffer[2] >> 6);
        value[3] = ((buffer[2] & 0x3F) << 4) | (buffer[1] >> 4);
        value[4] = ((buffer[1] & 0x0F) << 2) | (buffer[0] >> 6);
        value[5] = ((buffer[0] & 0x3F));
      }
    }
  }
}

public class BitalinoUnreadyException extends IOException {
}
