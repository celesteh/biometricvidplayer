import java.io.File;
import java.util.Properties;
import java.awt.*;
import java.util.*;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Arrays;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;


public class BiometricController {

  Properties prop;
  String path;
  biometric_player app;
  int breakcounter;
  Vector breakPoints;
  ControllerPanel gui;

  public BiometricController(biometric_player owner) {
    app = owner;
    prop = new Properties();
    breakcounter = 0;
    breakPoints = new Vector(2);
    gui = new ControllerPanel(this);
  }

  public BiometricController(biometric_player owner, String filePath) {
    this(owner);

    //InputStream inputStream;
    FileInputStream inputStream;

    path = filePath;
    //String propFileName = "config.properties";
    System.out.println(path);

    try {
      //ClassLoader loader = Thread.currentThread().getContextClassLoader();        
      //System.out.println("loader "+loader);
      //inputStream = getClass().getClassLoader().getResourceAsStream(path);
      //inputStream = loader.getResourceAsStream(path);

      inputStream = new FileInputStream(path);
      System.out.println("stream "+inputStream);

      if (inputStream != null) {
        System.out.println("Got stream");
        prop.load(inputStream);
      }
    }
    catch (Exception e)
    {
      //If the file ins't found, that's ok
      System.out.println("File exception: "+e);
    }
    //Date time = new Date(System.currentTimeMillis());

    breakPoints = new Vector(Arrays.asList(loadBreakPoints()));
  }

  public void write() {
    // output to file
  }

  /*
  public void read() {
   // reads from file
   }
   */

  public String getSetting(String name) {
    return prop.getProperty(name);
  }

  public void setSetting(String name, String value) {
    prop.setProperty(name, value);
  }


  public void start() {

    app.fadeIn();
  }

  public void stop() {
    app.fadeOut();
  }
  
  public void ready() {
    
    gui.ready();
  }

  public BreakPoint[] loadBreakPoints() {
    String key;
    Enumeration allNames;
    Vector keys = new Vector(2);
    //String[] keyarr;
    boolean newpoints;
    BreakPoint[] pointarr;

    allNames = prop.propertyNames();
    while (allNames.hasMoreElements()) {
      key = (String) allNames.nextElement();
      System.out.println(key);
      if (key.startsWith("break")) {
        keys.add(key);
      }
    }


    newpoints = false;
    if (breakPoints == null) { 
      newpoints = true;
    } else { 
      if (breakPoints.size() == 0) {
        newpoints = true;
      }
    }
    if (newpoints) {
      breakPoints = new Vector(keys.size()+2);
    }

    pointarr = new BreakPoint[keys.size()];


    //if(keys.size() > 0){
    //keyarr = new String[keys.size()];

    for (int i =0; i < keys.size(); i++) {
      pointarr[i] = new BreakPoint(prop.getProperty((String) keys.elementAt(i)));
    }

    Arrays.sort(pointarr);

    return pointarr;
  }

  public void addBreakPoint(BreakPoint point) {
    String key;
    int size = breakPoints.size();

    breakPoints.add(point);
    Collections.sort(breakPoints);

    key = "break"+size;
    this.setSetting(key, point.toString());
  }

  public BreakPoint getNextBreakPoint(double time) throws noFutureBreakPointsException {
    boolean found;
    BreakPoint point = null;
    double pointTime;
    found = false;

    for (int i = 0; (i < breakPoints.size()) && (! found); i++) {
      point = (BreakPoint) breakPoints.elementAt(i);
      pointTime = point.getTime();
      found = (pointTime > time);
    }

    if (! found) {
      point = null;
      throw new noFutureBreakPointsException();
    }
    return point;
  }

  public BreakPoint getFirstBreakPoint() {
    BreakPoint point=null;

    if (breakPoints.size() > 0) {
      point = (BreakPoint) breakPoints.elementAt(0);
    }

    //if ( point != null) {
    //  System.out.println(point.getTime());
    //}
    return point;
  }
}


public class ControllerPanel extends JFrame {

  BiometricController parent;
  JButton startbutton;
  JButton stopbutton;

  public ControllerPanel(BiometricController controller) {
    
    System.out.println("gui constructor");
    parent = controller;
    startbutton = new JButton("Start");
    startbutton.setActionCommand("start");
    startbutton.setEnabled(false);
   stopbutton = new JButton("Stop");
    stopbutton.setActionCommand("stop");
    stopbutton.setEnabled(false);

    JPanel newPanel = new JPanel(new GridBagLayout());

    GridBagConstraints constraints = new GridBagConstraints();
    constraints.anchor = GridBagConstraints.WEST;
    constraints.insets = new Insets(10, 10, 10, 10);

    // add components to the panel
    constraints.gridx = 0;
    constraints.gridy = 0;   
    newPanel.add(startbutton, constraints);

    constraints.gridx = 1;
    newPanel.add(stopbutton, constraints);

    // set border for the panel
    newPanel.setBorder(BorderFactory.createTitledBorder(
      BorderFactory.createEtchedBorder(), "Biometric Player"));

    // add the panel to this frame
    add(newPanel);

    pack();
    setLocationRelativeTo(null);
    this.setVisible(true);
  }

  public void play() {
    startbutton.setEnabled(false);
    stopbutton.setEnabled(true);
  }

  public void stop() {
    startbutton.setEnabled(true);
    stopbutton.setEnabled(false);
  }
  
  public void ready() {
    stop();
  }

  public void actionPerformed(ActionEvent e) {
    if ("play".equals(e.getActionCommand())) {
      parent.start();
      play();
    } else {
      if ("stop".equals(e.getActionCommand())) {
        parent.stop();
        stop();
      }
    }
  }
}


public class noFutureBreakPointsException extends Exception {
}
