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
d = Buffer.read(s, "/Users/Sean/Documents/Option 3 - ML Files for Students/Control Test Failures/Control Test-10.wav");

// now play it
(
y = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
Out.ar( out, PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 0))
}).play(s,[\bufnum, d.bufnum ]);
//)

 (
 // create a network address and assign it to a global variable
 ~toWekinator = NetAddr.new("127.0.0.1", 6448);
 )

//(
x = {
    var in, fft, array;
	in = PlayBuf.ar(1, d, BufRateScale.kr(d), loop: 0);
	filtered_in = LPF.ar(in: in, freq: 5300, mul: 1.0, add: 0.0); //Low pass filter with 5300Hz cutoff
    fft = FFT(LocalBuf(1024), filtered_in);  // for sampling rates 44100 and 48000
    array = MFCC.kr(fft);
	Out.kr(0, array); // control bus out
}.play;
//)

//(
c = Bus(\control, 0, 13);
//)

// send coefficients
//(
r = {

    inf.do {
		c.getn(13, { |val| ~toWekinator.sendMsg("/wek/inputs",*val[0..]) });
		0.01.wait; // 25 frames per second
    }
}.fork
)

r.stop;
s.stop;