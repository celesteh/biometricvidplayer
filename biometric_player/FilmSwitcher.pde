import processing.video.*;
import javax.bluetooth.*;
import java.util.Enumeration;
import java.util.Vector;

public class FilmSwitcher {

  BitReader bit;
  Movie mainFilm;
  Vector clips;
  PApplet parent;
  Movie active;
  boolean isPlaying;
  int count;

  public FilmSwitcher(PApplet app, String path, BitReader bitalino) {

    parent = app;
    mainFilm = new Movie(parent, path);
    bit = bitalino;
    active = mainFilm;
    mainFilm.loop();
    isPlaying = false;
    count = 0;
  }

  public Movie getActive() {
    active.speed(1.0);
    return active;
  }

  public void read() {
    /*
    if (count == 0) {
     try {
     final BITalinoFrame[] frames = bit.read();
     //System.out.println(frames[0]);
     } 
     catch (Exception e) {
     System.out.print("Exception " + e);
     }
     }
     count = (count + 1) % 5;
     */
    if (active.available()) {
      active.read();
    }
  }

  public void play() {
    isPlaying = true;
    mainFilm.play();
  }
}
