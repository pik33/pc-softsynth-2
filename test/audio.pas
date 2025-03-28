unit audio;

{$mode objfpc}{$H+}

interface

uses

  Classes, SysUtils;

//------ stereo samples types --------------------------------------------------

type PFloatsample=^Tfloatsample;
     TFloatsample=array[0..1] of single;
     Psample=^Tsample;
     Tsample=array[0..1] of smallint;


const zerofsample:TFloatsample=(0,0);
      zeroisample:Tsample=(0,0);

function cheby_lp_20k_192k(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_lowpass_128(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_bandpass_128_512(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_highpass_512(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_highpass_1200(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_highpass_1200_2(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_highpass_4000(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_highpass_4000_2(input:single; mode:integer):single;
function cheby_lowpass_20000_2(input:single; mode:integer):single;
function cheby_snr(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_snr2(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_snr(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct0(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct1(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct2(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct3(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct4(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct5(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct6(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct7(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct8(input:TFloatsample; mode:integer):Tfloatsample;
function bessel_oct9(input:TFloatsample; mode:integer):Tfloatsample;


function cheby_oct0(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct1(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct2(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct3(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct4(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct5(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct6(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct7(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct8(input:TFloatsample; mode:integer):Tfloatsample;
function cheby_oct9(input:TFloatsample; mode:integer):Tfloatsample;

function bessel_highpass_5000(input:TFloatsample; mode:integer):Tfloatsample;

implementation

// -----------------------------------------------------------------------------
// iir filters computed with mkfilter
// http://www-users.cs.york.ac.uk/~fisher/mkfilter/trad.html
//------------------------------------------------------------------------------

// --------------- Low pass Chebyshev filter 20k @ 192k ------------------------
// -----------------used when resampling to 192 kHz ----------------------------

function cheby_lp_20k_192k(input:TFloatsample; mode:integer):Tfloatsample;
var i:integer;

// Low pass Chebyshev filter 20k @ 192k
// computed with mkfilter http://www-users.cs.york.ac.uk/~fisher/mkfilter/trad.html
// used when resampling to 192 kHz

const xvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvl:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const xvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const yvr:array[0..8] of double=(0,0,0,0,0,0,0,0,0);
const gain= 2.366354733e+05 ;

begin
if mode=1 then for i:=0 to 8 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4]; xvl[4]:=xvl[5]; xvl[5]:=xvl[6]; xvl[6]:=xvl[7]; xvl[7]:=xvl[8];
//xvl[8]:=(0.00005*random+input[0])/gain;
xvl[8]:=input[0]/gain;

yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4]; yvl[4]:=yvl[5]; yvl[5]:=yvl[6]; yvl[6]:=yvl[7]; yvl[7]:= yvl[8];
yvl[8] :=   (xvl[0] + xvl[8]) + 8 * (xvl[1] + xvl[7]) + 28 * (xvl[2] + xvl[6])
             + 56 * (xvl[3] + xvl[5]) + 70 * xvl[4]
             + ( -0.3334450683 * yvl[0]) + (  2.7238758762 * yvl[1])
             + (-10.0475727760 * yvl[2]) + ( 21.8605976810 * yvl[3])
             + (-30.7017569250 * yvl[4]) + ( 28.5340593520 * yvl[5])
             + (-17.1697147400 * yvl[6]) + (  6.1328747665 * yvl[7]);
result[0] := yvl[8];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4]; xvr[4]:=xvr[5]; xvr[5]:=xvr[6]; xvr[6]:=xvr[7]; xvr[7]:=xvr[8];
//xvr[8]:=(0.00005*random+input[1])/gain;
xvr[8]:=input[1]/gain;

yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4]; yvr[4]:=yvr[5]; yvr[5]:=yvr[6]; yvr[6]:=yvr[7]; yvr[7]:= yvr[8];
yvr[8] :=   (xvr[0] + xvr[8]) + 8 * (xvr[1] + xvr[7]) + 28 * (xvr[2] + xvr[6])
             + 56 * (xvr[3] + xvr[5]) + 70 * xvr[4]
             + ( -0.3334450683 * yvr[0]) + (  2.7238758762 * yvr[1])
             + (-10.0475727760 * yvr[2]) + ( 21.8605976810 * yvr[3])
             + (-30.7017569250 * yvr[4]) + ( 28.5340593520 * yvr[5])
             + (-17.1697147400 * yvr[6]) + (  6.1328747665 * yvr[7]);
result[1] := yvr[8];
end;


function cheby_lowpass_128(input:TFloatsample; mode:integer):Tfloatsample;

//lowpass 128 Hz

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain= 5.225635480e+10;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) + 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.9891138421 * yvl[0]) + (  3.9672820428 * yvl[1])
             + ( -5.9672223686 * yvl[2]) + (  3.9890541676 * yvl[3]);

if yvl[4]>0 then result[0] := sqrt(yvl[4]) else result[0]:=-sqrt(-yvl[4]);

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];
yvr[4] :=   (xvr[0] + xvr[4]) + 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.9891138421 * yvr[0]) + (  3.9672820428 * yvr[1])
             + ( -5.9672223686 * yvr[2]) + (  3.9890541676 * yvr[3]);

result[1] := yvr[4];
end;

function cheby_bandpass_128_512(input:TFloatsample; mode:integer):Tfloatsample;

//bandpass 128-512 Hz

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain=7.787151088e+03;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 2 * xvl[2]
             + ( -0.9706293460 * yvl[0]) + (  3.9112351868 * yvl[1])
             + ( -5.9105802792 * yvl[2]) + (  3.9699744335 * yvl[3]);



if yvl[4]>0 then result[0] := sqrt(0.01+yvl[4])-0.1 else result[0]:=-sqrt(-yvl[4]+0.01)+0.1;

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];

yvr[4] :=   (xvr[0] + xvr[4]) - 2 * xvr[2]
             + ( -0.9706293460 * yvr[0]) + (  3.9112351868 * yvr[1])
             + ( -5.9105802792 * yvr[2]) + (  3.9699744335 * yvr[3]);



result[1] := yvr[4];
end ;

function cheby_highpass_512(input:TFloatsample; mode:integer):Tfloatsample;

//bandpass 128-512 Hz

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain=1.020705409e+00;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.9598652579 * yvl[0]) + (  3.8787286840 * yvl[1])
             + ( -5.8778516538 * yvl[2]) + (  3.9589881345 * yvl[3]);



if yvl[4]>0 then result[0] := sqrt(0.01+yvl[4])-0.1 else result[0]:=-sqrt(-yvl[4]+0.01)+0.1;

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];

yvr[4] :=   (xvr[0] + xvr[4]) - 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.9598652579 * yvr[0]) + (  3.8787286840 * yvr[1])
             + ( -5.8778516538 * yvr[2]) + (  3.9589881345 * yvr[3]);



result[1] := yvr[4];
end ;

 function cheby_highpass_1200(input:TFloatsample; mode:integer):Tfloatsample;

//bandpass 128-512 Hz

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain=1.049248095e+00;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.9084577425 * yvl[0]) + (  3.7207736755 * yvl[1])
             + ( -5.7160511554 * yvl[2]) + (  3.9037324853 * yvl[3]);




result[0] := yvl[4];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];

yvr[4] :=   (xvr[0] + xvr[4]) - 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.9084577425 * yvr[0]) + (  3.7207736755 * yvr[1])
             + ( -5.7160511554 * yvr[2]) + (  3.9037324853 * yvr[3]);

result[1] := yvr[4];
end;

function cheby_highpass_1200_2(input:TFloatsample; mode:integer):Tfloatsample;

//nonlinear enhancer

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain=1.049248095e+00;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
            + ( -0.9084577425 * yvl[0]) + (  3.7207736755 * yvl[1])
            + ( -5.7160511554 * yvl[2]) + (  3.9037324853 * yvl[3]);




if yvl[4]>0 then result[0] := sqrt(0.01+yvl[4])-0.1 else result[0]:=-sqrt(-yvl[4]+0.01)+0.1;
result[0]+=sqr(yvl[4]);
result[0]+=sqr(sqr(yvl[4]));

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];

yvr[4] :=   (xvr[0] + xvr[4]) - 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
            + ( -0.9084577425 * yvr[0]) + (  3.7207736755 * yvr[1])
            + ( -5.7160511554 * yvr[2]) + (  3.9037324853 * yvr[3]);

if yvr[4]>0 then result[1] := sqrt(0.01+yvr[4])-0.1 else result[1]:=-sqrt(-yvr[4]+0.01)+0.1;
result[1]+=sqr(yvr[4]);
result[1]+=sqr(sqr(yvr[4]));
end;

function cheby_highpass_4000(input:TFloatsample; mode:integer):Tfloatsample;

//bandpass 128-512 Hz

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain=1.174493211e+00 ;


var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.7260936160 * yvl[0]) + (  3.1338297606 * yvl[1])
             + ( -5.0855065911 * yvl[2]) + (  3.6774669947 * yvl[3]);





result[0] := yvl[4];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];

yvr[4] :=   (xvr[0] + xvr[4]) - 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.7260936160 * yvr[0]) + (  3.1338297606 * yvr[1])
             + ( -5.0855065911 * yvr[2]) + (  3.6774669947 * yvr[3]);


result[1] := yvr[4];

end;

function bessel_highpass_5000(input:TFloatsample; mode:integer):Tfloatsample;

                //cheby 6k

const xvl:array[0..3] of double=(0,0,0,0);
const yvl:array[0..3] of double=(0,0,0,0);
const xvr:array[0..3] of double=(0,0,0,0);
const yvr:array[0..3] of double=(0,0,0,0);
const gain= 1.26972061133281e+000;


var i:integer;

begin

if mode=1 then for i:=0 to 3 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

  xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3];
  xvl[3] := input[0]/ GAIN;
  yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3];
  yvl[3] :=   (xvl[3] - xvl[0]) + 3 * (xvl[1] - xvl[2])
  + (  0.60588746352217 * yvl[0]) + ( -2.15642557866146 * yvl[1])
  + (  2.53828563172660 * yvl[2]);

result[0] := yvl[3];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3];
xvr[3] := input[1]/gain;
yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3];
yvr[3] :=   (xvr[3] - xvr[0]) + 3 * (xvr[1] - xvr[2])
+ (  0.60588746352217 * yvr[0]) + ( -2.15642557866146 * yvr[1])
+ (  2.53828563172660 * yvr[2]);



result[1] := yvr[3];

end;

function cheby_highpass_4000_2(input:single; mode:integer):single;

//bandpass 128-512 Hz

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);

const gain=1.174493211e+00 ;


var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; yvl[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.7260936160 * yvl[0]) + (  3.1338297606 * yvl[1])
             + ( -5.0855065911 * yvl[2]) + (  3.6774669947 * yvl[3]);



result := yvl[4];



end;

function cheby_lowpass_20000_2(input:single; mode:integer):single;



const xv:array[0..4] of double=(0,0,0,0,0);
const yv:array[0..4] of double=(0,0,0,0,0);

const gain=1.822793671e+02;


var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xv[i]:=0; yv[i]:=0; end;

xv[0]:=xv[1]; xv[1]:=xv[2]; xv[2]:=xv[3]; xv[3]:=xv[4];
xv[4]:=input/gain;
yv[0]:=yv[1]; yv[1]:=yv[2]; yv[2]:=yv[3]; yv[3]:=yv[4];
yv[4] :=   (xv[0] + xv[4]) + 4 * (xv[1] + xv[3]) + 6 * xv[2]
             + ( -0.3102710604 * yv[0]) + (  1.4411732838 * yv[1])
             + ( -2.7232240533 * yv[2]) + (  2.5045444789 * yv[3]);


result := yv[4];
end;

function cheby_snr(input:TFloatsample; mode:integer):Tfloatsample;

//highpass 150 Hz chebyshev filter for SNR estimating

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain=1.006019470e+00;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.9880710642 * yvl[0]) + (  3.9641373812 * yvl[1])
             + ( -5.9640613147 * yvl[2]) + (  3.9879949969 * yvl[3]);
result[0] := yvl[4];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];
yvr[4] :=   (xvr[0] + xvr[4]) - 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.9880710642 * yvr[0]) + (  3.9641373812 * yvr[1])
             + ( -5.9640613147 * yvr[2]) + (  3.9879949969 * yvr[3]);
result[1] := yvr[4];
end;


function cheby_snr2(input:TFloatsample; mode:integer):Tfloatsample;

//lowpass 12k chebyshev filter for SNR estimating

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain= 1.141054352e+03;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;

xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) + 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.4935903853 * yvl[0]) + (  2.2359402623 * yvl[1])
             + ( -3.9189613363 * yvl[2]) + (  3.1625893402 * yvl[3]);

result[0] := yvl[4];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];
yvr[4] :=   (xvr[0] + xvr[4]) + 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.4935903853 * yvr[0]) + (  2.2359402623 * yvr[1])
             + ( -3.9189613363 * yvr[2]) + (  3.1625893402 * yvr[3]);

result[1] := yvr[4];
end;


function bessel_snr(input:TFloatsample; mode:integer):Tfloatsample;

//A rough approximation of noise weight A curve
//200 Hz highpass Bessel filter

const xvl:array[0..4] of double=(0,0,0,0,0);
const yvl:array[0..4] of double=(0,0,0,0,0);
const xvr:array[0..4] of double=(0,0,0,0,0);
const yvr:array[0..4] of double=(0,0,0,0,0);
const gain= 1.006938345e+00;

var i:integer;

begin

if mode=1 then for i:=0 to 4 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2]; xvl[2]:=xvl[3]; xvl[3]:=xvl[4];
xvl[4]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2]; yvl[2]:=yvl[3]; yvl[3]:=yvl[4];
yvl[4] :=   (xvl[0] + xvl[4]) - 4 * (xvl[1] + xvl[3]) + 6 * xvl[2]
             + ( -0.9862596639 * yvl[0]) + (  3.9586976432 * yvl[1])
             + ( -5.9586160446 * yvl[2]) + (  3.9861780649 * yvl[3]);

result[0] := yvl[4];
xvr[0]:=xvr[1]; xvr[1]:=xvr[2]; xvr[2]:=xvr[3]; xvr[3]:=xvr[4];
xvr[4]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2]; yvr[2]:=yvr[3]; yvr[3]:=yvr[4];
yvr[4] :=   (xvr[0] + xvr[4]) - 4 * (xvr[1] + xvr[3]) + 6 * xvr[2]
             + ( -0.9862596639 * yvr[0]) + (  3.9586976432 * yvr[1])
             + ( -5.9586160446 * yvr[2]) + (  3.9861780649 * yvr[3]);

result[1] := yvr[4];
end;

// one octave bessel filter bank

// octave 0 20-40

function bessel_oct0(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain=3.01518411301128e+003;
var i:integer;

begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
             + ( -0.99934571562121 * yvl[0]) + (  1.99934485916502 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
             + ( -0.99934571562121 * yvr[0]) + (  1.99934485916502 * yvr[1]);
result[1] := yvr[2];
end;

// octave 1 40-80

function bessel_oct1(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain= 1.50808513026032e+003;
var i:integer;

begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
              + ( -0.99869185905046 * yvl[0]) + (  1.99868843434645 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
             + ( -0.99869185905046 * yvr[0]) + (  1.99868843434645 * yvr[1]);
result[1] := yvr[2];
end;

// octave 2 80-160

function bessel_oct2(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain=7.54535515750293e+002;
var i:integer;

begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
              + ( -0.99738542709660 * yvl[0]) + (  1.99737173724053 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
              + ( -0.99738542709660 * yvr[0]) + (  1.99737173724053 * yvr[1]);
result[1] := yvr[2];
end;

// octave 3 160-320

function bessel_oct3(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain= 3.77760462382205e+002;
var i:integer;

begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
             + ( -0.99477767233478 * yvl[0]) + (  1.99472298449724 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
             + ( -0.99477767233478 * yvr[0]) + (  1.99472298449724 * yvr[1]);
result[1] := yvr[2];
end;

// octave 4 320-640

function bessel_oct4(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain=  1.89372444166688e+002;
var i:integer;

begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
             + ( -0.98958247531875 * yvl[0]) + (  1.98936429517978 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
              + ( -0.98958247531875 * yvr[0]) + (  1.98936429517978 * yvr[1]);
result[1] := yvr[2];
end;

//octave 5 640-1280


function bessel_oct5(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
var i:integer;
const gain=9.51774547237725e+001;
begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
               + ( -0.97927235072578 * yvl[0]) + (  1.97840417645719 * yvr[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
                + ( -0.97927235072578 * yvr[0]) + (  1.97840417645719 * yvr[1]);
result[1] := yvr[2];
end;

// octave 6 1280-2560


function bessel_oct6(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain=4.80780099638712e+001;
var i:integer;
begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
               + ( -0.95896552196290 * yvl[0]) + (  1.95552883077642 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
                + ( -0.95896552196290 * yvr[0]) + (  1.95552883077642 * yvr[1]);
result[1] := yvr[2];
end;


// octave 7 2560-5120


function bessel_oct7(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain=2.45244277243063e+001;
var i:integer;
begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
              + ( -0.91954713790704 * yvl[0]) + (  1.90608289392734 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
               + ( -0.91954713790704 * yvr[0]) + (  1.90608289392734 * yvr[1]);
result[1] := yvr[2];
end;


// octave 8 5120-10240

function bessel_oct8(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain=1.27400582314107e+001;
var i:integer;
begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
              + ( -0.84506551949186 * yvl[0]) + (  1.79338906121695 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
              + ( -0.84506551949186 * yvr[0]) + (  1.79338906121695 * yvr[1]);
result[1] := yvr[2];
end;


// octave 9 10240-20480

function bessel_oct9(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..2] of double=(0,0,0);
const yvl:array[0..2] of double=(0,0,0);
const xvr:array[0..2] of double=(0,0,0);
const yvr:array[0..2] of double=(0,0,0);
const gain= 6.83310279937244e+000 ;
var i:integer;
begin

if mode=1 then for i:=0 to 2 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0]:=xvl[1]; xvl[1]:=xvl[2];
xvl[2]:=input[0]/gain;
yvl[0]:=yvl[1]; yvl[1]:=yvl[2];
yvl[2] :=   (xvl[2] - xvl[0])
            + ( -0.71066300938115 * yvl[0]) + (  1.52035643761664 * yvl[1]);
result[0] := yvl[2];

xvr[0]:=xvr[1]; xvr[1]:=xvr[2];
xvr[2]:=input[1]/gain;
yvr[0]:=yvr[1]; yvr[1]:=yvr[2];
yvr[2] :=   (xvr[2] - xvr[0])
             + ( -0.71066300938115 * yvr[0]) + (  1.52035643761664 * yvr[1]);
result[1] := yvr[2];
end;


// one octave cheby filter bank

// octave 0 20-40

function cheby_oct0(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..3] of double=(0,0,0,0);
const yvl:array[0..3] of double=(0,0,0,0);
const xvr:array[0..3] of double=(0,0,0,0);
const yvr:array[0..3] of double=(0,0,0,0);
const gain=7.26444449217841e+009;
var i:integer;

begin

if mode=1 then for i:=0 to 3 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;
xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3];
xvl[3] := input[0]/gain;
yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3];
yvl[3] :=   (xvl[0] + xvl[3]) + 3 * (xvl[1] + xvl[2])
                       + (  0.99870710094231 * yvl[0]) + ( -2.99741208182685 * yvl[1])
                       + (  2.99870497978329 * yvl[2]);
result[0] := yvl[3];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3];
xvr[3] := input[1]/gain;
yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3];
yvr[3] :=   (xvr[0] + xvr[3]) + 3 * (xvr[1] + xvr[2])
                       + (  0.99870710094231 * yvr[0]) + ( -2.99741208182685 * yvr[1])
                       + (  2.99870497978329 * yvr[2]);

result[1] := yvr[3];
end;

// octave 1 40-80

function cheby_oct1(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain= 2.33545178699357e+006;
var i:integer;

begin

 if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4];
          xvl[4] := input[0] / gain;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4];
          yvl[4] :=   (xvl[0] + xvl[4]) - 2 * xvl[2]
                        + ( -0.99815051119192 * yvl[0]) + (  3.99444297730664 * yvl[1])
                        + ( -5.99443441471117 * yvl[2]) + (  3.99814194858471 * yvl[3]);


result[0] := yvl[4];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4];
          xvr[4] := input[1] / gain;
          yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4];
          yvr[4] :=   (xvr[0] + xvr[4]) - 2 * xvr[2]
                        + ( -0.99815051119192 * yvr[0]) + (  3.99444297730664 * yvr[1])
                        + ( -5.99443441471117 * yvr[2]) + (  3.99814194858471 * yvr[3]);

result[1] := yvr[4];
end;

// octave 2 80-160

function cheby_oct2(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain=  5.84466294028199e+005;
var i:integer;

begin

 if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4];
          xvl[4] := input[0] / gain;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4];
          yvl[4] :=   (xvl[0] + xvl[4]) - 2 * xvl[2]
          + ( -0.99630444299269 * yvl[0]) + (  3.98887914823606 * yvl[1])
          + ( -5.98884491702376 * yvl[2]) + (  3.99627021159282 * yvl[3]);


result[0] := yvl[4];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4];
          xvr[4] := input[1] / gain;
          yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4];
          yvr[4] :=   (xvr[0] + xvr[4]) - 2 * xvr[2]
          + ( -0.99630444299269 * yvr[0]) + (  3.98887914823606 * yvr[1])
          + ( -5.98884491702376 * yvr[2]) + (  3.99627021159282 * yvr[3]);

result[1] := yvr[4];
end;

// octave 3 160-320

function cheby_oct3(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain=  1.10426722049060e+008;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.99483842737979 * yvl[0]) + (  5.97399452356711 * yvl[1])
          + (-14.94759319494522 * yvl[2]) + ( 19.94719670640127 * yvl[3])
          + (-14.97339978532117 * yvl[4]) + (  5.99464017767764 * yvl[5]);

result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.99483842737979 * yvr[0]) + (  5.97399452356711 * yvr[1])
         + (-14.94759319494522 * yvr[2]) + ( 19.94719670640127 * yvr[3])
         + (-14.97339978532117 * yvr[4]) + (  5.99464017767764 * yvr[5]);

result[1] := yvr[6];
end;


// octave 4 320-640

function cheby_oct4(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain=1.38376005504288e+007;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.98970351393896 * yvl[0]) + (  5.94773043766543 * yvl[1])
          + (-14.89388170647537 * yvl[2]) + ( 19.89229746036456 * yvl[3])
          + (-14.94535398179565 * yvl[4]) + (  5.98891130416949 * yvl[5]);

result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.98970351393896 * yvr[0]) + (  5.94773043766543 * yvr[1])
         + (-14.89388170647537 * yvr[2]) + ( 19.89229746036456 * yvr[3])
         + (-14.94535398179565 * yvr[4]) + (  5.98891130416949 * yvr[5]);


result[1] := yvr[6];
end;


//octave 5 640-1280


function cheby_oct5(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain=1.73939598864656e+006;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.97951318283641 * yvl[0]) + (  5.89444388650542 * yvl[1])
          + (-14.78260605612011 * yvl[2]) + ( 19.77628394420148 * yvl[3])
          + (-14.88495933745285 * yvl[4]) + (  5.97635074503433 * yvl[5]);

result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.97951318283641 * yvr[0]) + (  5.89444388650542 * yvr[1])
         + (-14.78260605612011 * yvr[2]) + ( 19.77628394420148 * yvr[3])
         + (-14.88495933745285 * yvr[4]) + (  5.97635074503433 * yvr[5]);


result[1] := yvr[6];
end;

// octave 6 1280-2560


function cheby_oct6(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain=2.19676838049273e+005;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.95944715095846 * yvl[0]) + (  5.78495850722365 * yvl[1])
          + (-14.54508601607050 * yvl[2]) + ( 19.51993558928874 * yvl[3])
          + (-14.74721098992971 * yvl[4]) + (  5.94685001815033 * yvl[5]);

result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.95944715095846 * yvr[0]) + (  5.78495850722365 * yvr[1])
         + (-14.54508601607050 * yvr[2]) + ( 19.51993558928874 * yvr[3])
         + (-14.74721098992971 * yvr[4]) + (  5.94685001815033 * yvr[5]);


result[1] := yvr[6];
end;

// octave 7 2560-5120


function cheby_oct7(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain= 2.80301886662481e+004;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.92054707450167 * yvl[0]) + (  5.55529438420478 * yvl[1])
          + (-14.01387710875280 * yvl[2]) + ( 18.91467386842076 * yvl[3])
          + (-14.40614824294723 * yvl[4]) + (  5.87060152817974 * yvl[5]);

result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.92054707450167 * yvr[0]) + (  5.55529438420478 * yvr[1])
         + (-14.01387710875280 * yvr[2]) + ( 18.91467386842076 * yvr[3])
         + (-14.40614824294723 * yvr[4]) + (  5.87060152817974 * yvr[5]);


result[1] := yvr[6];
end;

// octave 8 5120-10240

function cheby_oct8(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain= 3.64984033310809e+003;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.84746709134038 * yvl[0]) + (  5.06059362734676 * yvl[1])
          + (-12.75871698807304 * yvl[2]) + ( 17.37740268733801 * yvl[3])
          + (-13.48353843021159 * yvl[4]) + (  5.65156524028229 * yvl[5]);


result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.84746709134038 * yvr[0]) + (  5.06059362734676 * yvr[1])
         + (-12.75871698807304 * yvr[2]) + ( 17.37740268733801 * yvr[3])
         + (-13.48353843021159 * yvr[4]) + (  5.65156524028229 * yvr[5]);


result[1] := yvr[6];
end;


// octave 9 10240-20480

function cheby_oct9(input:TFloatsample; mode:integer):Tfloatsample;

const xvl:array[0..6] of double=(0,0,0,0,0,0,0);
const yvl:array[0..6] of double=(0,0,0,0,0,0,0);
const xvr:array[0..6] of double=(0,0,0,0,0,0,0);
const yvr:array[0..6] of double=(0,0,0,0,0,0,0);
const gain= 4.94419711021100e+002;
var i:integer;

begin
if mode=1 then for i:=0 to 6 do begin xvl[i]:=0; xvr[i]:=0; yvl[i]:=0; yvr[i]:=0; end;


xvl[0] := xvl[1]; xvl[1] := xvl[2]; xvl[2] := xvl[3]; xvl[3] := xvl[4]; xvl[4] := xvl[5]; xvl[5] := xvl[6];
          xvl[6] := input[0] / GAIN;
          yvl[0] := yvl[1]; yvl[1] := yvl[2]; yvl[2] := yvl[3]; yvl[3] := yvl[4]; yvl[4] := yvl[5]; yvl[5] := yvl[6];
          yvl[6] :=   (xvl[6] - xvl[0]) + 3 * (xvl[2] - xvl[4])
          + ( -0.71859451484245 * yvl[0]) + (  3.98450847155511 * yvl[1])
          + ( -9.75538725630545 * yvl[2]) + ( 13.40710275446356 * yvl[3])
          + (-10.89765122546993 * yvl[4]) + (  4.97088102565487 * yvl[5]);



result[0] := yvl[6];

xvr[0] := xvr[1]; xvr[1] := xvr[2]; xvr[2] := xvr[3]; xvr[3] := xvr[4]; xvr[4] := xvr[5]; xvr[5] := xvr[6];
         xvr[6] := input[1] / GAIN;
         yvr[0] := yvr[1]; yvr[1] := yvr[2]; yvr[2] := yvr[3]; yvr[3] := yvr[4]; yvr[4] := yvr[5]; yvr[5] := yvr[6];
         yvr[6] :=   (xvr[6] - xvr[0]) + 3 * (xvr[2] - xvr[4])
         + ( -0.71859451484245 * yvr[0]) + (  3.98450847155511 * yvr[1])
         + ( -9.75538725630545 * yvr[2]) + ( 13.40710275446356 * yvr[3])
         + (-10.89765122546993 * yvr[4]) + (  4.97088102565487 * yvr[5]);



result[1] := yvr[6];
end;



end.

