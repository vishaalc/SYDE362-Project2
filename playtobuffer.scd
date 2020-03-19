(
// s = Server.local;
// s.options.device = "H5";
// s.options.numInputBusChannels = 2;
// s.options.numOutputBusChannels = 2;
s.boot;
)

// read a soundfile
//d = Buffer.read(s, "/home/matt/ownCloud/TEACHING/2020/SYDE362-W2020/Deliverables/P2 ML/s1.wav");
/*d = Buffer.read(s, "/Users/Sean/Documents/Option 3 - ML Files for Students/Isolated Failure Sounds/A.wav");*/
d = Buffer.read(s, "/Users/Neil/Documents/Projects/362-ML/Option 3 - ML Files for Students/Control Test Failures/Control Test-10.wav");

// now play it
(
y = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
Out.ar( out, PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 0))
}).play(s,[\bufnum, d.bufnum ]);
)

 (
 // create a network address and assign it to a global variable
 ~toWekinator = NetAddr.new("127.0.0.1", 6448);
 ~toProcessing = NetAddr.new("127.0.0.1", 12000);
 )

(
c = Bus(\control, 0, 13);
)

(
x = {
	var in, fft, array;
	in = PlayBuf.ar(1, d, BufRateScale.kr(d), loop: 0);
    fft = FFT(LocalBuf(1024), in);  // for sampling rates 44100 and 48000
    array = MFCC.kr(fft);
	Out.kr(0, array); // control bus out
}.play;
)


// send coefficients
(
 ~toWekinator.sendMsg("/wekinator/control/outputs","0", "0", "0", "0");
 ~toProcessing.sendMsg("/event","start");
 r = {
	 inf.do {
		 c.getn(13, { |val| ~toWekinator.sendMsg("/wek/inputs",*val[0..]) });
		 0.01.wait; // 25 frames per second
	 }
 }.fork
)

(~toProcessing.sendMsg("/event","end");)

r.stop;
s.stop;