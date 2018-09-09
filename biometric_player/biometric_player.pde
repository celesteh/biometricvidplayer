import processing.video.*;

Movie myMovie;
//Rectangle monitor;
double start_time;

Bitalino bit;

// bitalino


void setup() {
  size(200, 200);

  bit = new Bitalino(this);
  bit.getPorts();

    /*
  GraphicsDevice gd;

  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[] gs = ge.getScreenDevices();
  // gs[1] gets the *second* screen. gs[0] would get the primary screen
  if (gs.length > 1) {
    gd = gs[1];
  } else {
    gd = gs[0];
  }

  //GraphicsConfiguration[] gc = gs[0].getDefaultConfiguration();//getConfigurations();

  monitor = new Rectangle();
  monitor = gs[0].getDefaultConfiguration().getBounds();//gc[0].getBounds();

  //frame.setLocation((int)(monitor.width / 2), (int)(monitor.height / 2));
  //frame.setLocation((int)(monitor.x + (monitor.width / 2)),
  //                  (int)(monitor.y +(monitor.height / 2)));
  frame.setLocation((int) monitor.x, (int) monitor.y);
  frame.setAlwaysOnTop(true);

  GraphicsConfiguration grc = gd.getDefaultConfiguration();
  javax.swing.JFrame f = new javax.swing.JFrame(/*"Score"*//*grc);
  f.removeNotify();
  f.setUndecorated(true);
  f.addNotify();
  f.add(viewer);

  int xoffs = grc.getBounds().x;
  int yoffs = grc.getBounds().y;
  f.setLocation(xoffs, yoffs);

  f.pack();
  f.setVisible(true);
  background(1);
  */


  myMovie = new Movie(this, /*dataPath("") ++*/ "DRAFT_JERWOOD_04.09.18.mp4");
  myMovie.play();
}

void draw() {
  image(myMovie, 0, 0);
}

void movieEvent(Movie m) {
  m.read();
}



/*
  public java.awt.Dimension getPreferredSize() {

    return new java.awt.Dimension(monitor.width, monitor. height);
  }
 */
