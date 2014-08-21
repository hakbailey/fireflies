// changes to main sketch needed to incorporate:
// pass an int to the constructor for port number (as returned by Serial.list()) to use
// change event functions to include the reference to which headset caused event
// call mindset.update() in main draw() loop


// public void eegEvent(int _delta, int theta, int low_alpha, int high_alpha, int low_beta, int high_beta, int low_gamma, int mid_gamma) {
// void poorSignalEvent(int sig) {
// public void attentionEvent(int attentionLevel) {
// void meditationEvent(int meditationLevel) {
// void blinkEvent(int blinkStrength) {
// public void eegEvent(int delta, int theta, int low_alpha, int high_alpha, int low_beta, int high_beta, int low_gamma, int mid_gamma) {
// void rawEvent(int[] raw) {


import processing.serial.*;

class MindSetSerial {

  // data parsing constants
  private static final int SYNC = 0xAA;
  private static final int EXCODE = 0X55;

  // instance variables
  private Serial port;
  private boolean on = false;
  //private static int count = 0;
  private int id;

  //MindSet readings
  public int rawWave = 0;
  public int attention = 0;
  public int meditation = 0;
  public boolean signal = false;         // ture -> good signal, false -> poor signal

  // EEG Readings
  public long delta = 0;         // 0.5 - 2.75Hz
  public long theta = 0;         // 3.5 - 6.75Hz
  public long lowAlpha = 0;      // 7.5 - 9.25Hz
  public long highAlpha = 0;     // 10 - 11.75Hz
  public long lowBeta = 0;       // 13 - 16.75Hz
  public long highBeta = 0;      // 18 - 29.75Hz
  public long lowGamma = 0;      // 31 - 39.75Hz
  public long midGamma = 0;      // 41 - 49.75Hz

  /*public int getId() {
   return id;
   }*/

  void start() {
    on = true;
  }

  void stop() {
    on = false;
  }

  void update() {
    if (on) {
      while (port.available () > 0)
      {
        char[] payload = new char[256];
        char pLength = 256;

        /* Synchronize on [SYNC] bytes */
        char c = port.readChar(); //fread( &c, 1, 1, stream ); 
        if ( c != SYNC ) continue;

        c = port.readChar(); //fread( &c, 1, 1, stream ); 
        if ( c != SYNC ) continue;

        // Parse [PLENGTH] byte
        while ( true && port.available () > 0) { 
          pLength = port.readChar(); //fread( &pLength, 1, 1, stream );

          if (pLength != 170) break;
        } 
        if ( pLength > 170 ) continue;

        // Collect [PAYLOAD...] bytes
        int count = 0;
        while (port.available () > 0 && count < pLength)
        {
          payload[count] = port.readChar();
          //print((int)payload[count] + ",");
          count++;
        }
        if (count < pLength) continue;

        // Calculate [PAYLOAD...] checksum 
        int checksum = 0; 
        for (char i=0; i<pLength; i++ ) checksum += payload[i]; 

        checksum &= 0xFF; 
        checksum = ~checksum & 0xFF; 

        // Parse [CKSUM] byte
        if (port.available() > 0) c = port.readChar(); //fread( &c, 1, 1, stream );
        else continue;

        // Verify [CKSUM] byte against calculated [PAYLOAD...] checksum
        if ( c != checksum ) continue;

        /*print("Length: " + (int)pLength + ", Payload: ");
         
         for(int i = 0; i < pLength; i++)
         {
         print(payload[i]);
         }
         
         println(", Checksum: " + checksum);*/

        // Since [CKSUM] is OK, parse the Data Payload
        parsePayload(payload, pLength);
      } // while(port.available())
    } // if(on)
  } // update()


  MindSetSerial(int portNum, PApplet applet, int id) {
    port = new Serial(applet, Serial.list()[portNum], 57600);
    this.id = id;
  }

  private void parsePacket()
  {
    while (port.available () > 0)
    {
      char[] payload = new char[256];
      char pLength = 256;

      /* Synchronize on [SYNC] bytes */
      char c = port.readChar(); //fread( &c, 1, 1, stream ); 
      if ( c != SYNC ) continue;

      c = port.readChar(); //fread( &c, 1, 1, stream ); 
      if ( c != SYNC ) continue;

      // Parse [PLENGTH] byte
      while ( true && port.available () > 0) { 
        pLength = port.readChar(); //fread( &pLength, 1, 1, stream );

        if (pLength != 170) break;
      } 
      if ( pLength > 170 ) continue;

      // Collect [PAYLOAD...] bytes
      int count = 0;
      while (port.available () > 0 && count < pLength)
      {
        payload[count] = port.readChar();
        //print((int)payload[count] + ",");
        count++;
      }
      if (count < pLength) continue;

      // Calculate [PAYLOAD...] checksum 
      int checksum = 0; 
      for (char i=0; i<pLength; i++ ) checksum += payload[i]; 

      checksum &= 0xFF; 
      checksum = ~checksum & 0xFF; 

      // Parse [CKSUM] byte
      if (port.available() > 0) c = port.readChar(); //fread( &c, 1, 1, stream );
      else continue;

      // Verify [CKSUM] byte against calculated [PAYLOAD...] checksum
      if ( c != checksum ) continue;

      /*print("Length: " + (int)pLength + ", Payload: ");
       
       for(int i = 0; i < pLength; i++)
       {
       print(payload[i]);
       }
       
       println(", Checksum: " + checksum);*/

      // Since [CKSUM] is OK, parse the Data Payload
      parsePayload(payload, pLength);
    }
  }

  private void parsePayload(char[] payload, char pLength)
  {
    int bytesParsed = 0;
    int code;
    int len;
    int extendedCodeLevel;

    while (bytesParsed < pLength)
    {
      extendedCodeLevel = 0;
      while (payload[bytesParsed] == EXCODE) {
        extendedCodeLevel++;
        bytesParsed++;
      }
      code = (int)payload[bytesParsed++];

      if (code >= 0x80)  len = (int)payload[bytesParsed++];
      else              len = 1;

      switch(code) {

      case 0x80:  // RAW WAVE
        int highValue = (int)payload[bytesParsed++];
        int lowValue = (int)payload[bytesParsed];

        rawWave = (highValue << 8) | lowValue;

        if (rawWave > 32768) rawWave = rawWave - 65536;

        //if(signal) println("Raw Wave: " + rawWave);      // do not print if you are experiencing a poor signal
        break;

      case 0x02:  // POOR SIGNAL
        if ((int)payload[bytesParsed] == 200) signal = false;
        else signal = true;

        if (!signal) println("POOR SIGNAL");
        break;

      case 0x83:  // EEG DATA
        int[] eegData = new int[24];

        for (int i = 0; i < len; i++) eegData[i] = (int)payload[bytesParsed + i];

        delta = ((eegData[0] << 16) | (eegData[1] << 8)) | eegData[2];
        theta = ((eegData[3] << 16) | (eegData[4] << 8)) | eegData[5];
        lowAlpha = ((eegData[6] << 16) | (eegData[7] << 8)) | eegData[8];
        highAlpha = ((eegData[9] << 16) | (eegData[10] << 8)) | eegData[11];
        lowBeta = ((eegData[12] << 16) | (eegData[13] << 8)) | eegData[14];
        highBeta = ((eegData[15] << 16) | (eegData[16] << 8)) | eegData[17];
        lowGamma = ((eegData[18] << 16) | (eegData[19] << 8)) | eegData[20];
        midGamma = ((eegData[21] << 16) | (eegData[22] << 8)) | eegData[23];

        // do not print if you are experiencing a poor signal
        if (signal) println("EEG Power Values: " + delta + "," + theta + "," + lowAlpha + "," + highAlpha + "," + lowBeta + "," + highBeta + "," + lowGamma + "," + midGamma);
        break;

      case 0x04:  // ATTENTION
        attention = (int)payload[bytesParsed];
        if (signal) {
          println(id);
          println("Attention: " + attention);    // do not print if you are experiencing a poor signal
        }
        break;

      case 0x05:  // MEDITATION
        meditation = (int)payload[bytesParsed];
        if (signal) println("Meditation: " + meditation);  // do not print if you are experiencing a poor signal
        break;
      }

      //println("EXCODE level: " + (int)extendedCodeLevel + " CODE: 0x" + hex(code,2) + " length: " + len);
      //print("Data value(s):");

      /*for(int i = 0; i < len; i++)
       {
       print(int(payload[bytesParsed + i]) & 0xFF);
       print(",");
       }*/

      bytesParsed += len;
    }
  }
};

