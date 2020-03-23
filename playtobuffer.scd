//Before doing anything, make sure that wekinator and processing are running

// 1. Run this block
(
// s = Server.local;
// s.options.device = "H5";
// s.options.numInputBusChannels = 2;
// s.options.numOutputBusChannels = 2;
s.boot;
)

// 2. Run this block to get the file
(
d = Buffer.read(s, "/Users/Sean/Documents/Option 3 - ML Files for Students/Control Test Failures/Control Test-50.wav");
)

// 3. Run this block to set up communication to wekinator and processing.
//    You may have to run both lines separately.
(
 // create a network address and assign it to a global variable
	~toWekinator = NetAddr.new("127.0.0.1", 6448);
	~toProcessing = NetAddr.new("127.0.0.1", 12000);
)

// 4. Run this whole block of code at once to play the file a single time and send it
(
~toProcessing.sendMsg("/event","start");

y = SynthDef("tutorial-PlayBuf",{ arg out = 0, bufnum;
Out.ar( out, PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 0))
}).play(s,[\bufnum, d.bufnum ]);

x = {
    var in, fft, array, filtered_in;
	in = PlayBuf.ar(1, d, BufRateScale.kr(d), loop: 0);
	filtered_in = LPF.ar(in: in, freq: 5300, mul: 1.0, add: 0.0); //Low pass filter with 5300Hz cutoff
    fft = FFT(LocalBuf(1024), filtered_in);  // for sampling rates 44100 and 48000
    array = MFCC.kr(fft);
	Out.kr(0, array); // control bus out
}.play;

c = Bus(\control, 0, 13);

// send coefficients
r = {

    inf.do {
		c.getn(13, { |val| ~toWekinator.sendMsg("/wek/inputs",*val[0..]) });
		0.01.wait; // 25 frames per second
    }
}.fork
)

// 5. Run this block last. Processing listens for this and then outputs its results to a csv file
(
~toProcessing.sendMsg("/event","end");
)

)
r.stop;
s.stop;