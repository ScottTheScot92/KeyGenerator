% Author name: Scott Lockerbie Todd
% Email: scott@todd.science
%
% SOME DOCUMENTATION
% 
% INPUTS
%
% 1) Allowed Chars
% Choose which characters are to appear in the password. Any ASCII
% character, bar the ASCII character represented by '0', should be
% supported (though perhaps not recommended). Specify ranges using a
% hyphen, such as 'A-Z' or '0-9'. Note that case IS sensitive, as 'a' and
% 'A' are different ASCII characters. Further note that the function
% converts input ranges into a range in ASCII meaning that inputs such as
% '0-z' are accepted, however consult an ASCII table if you wish to pull
% this kind of nonsense ('0-z' grabs characters such as '@' and '?').

% 2) KeypassDim
% KeypassDim is a 1x2 array that allows one to format the output password
% into a rectangular array with dimensions specified by the two numbers.
% The first element specifies the number of rows, and the second element
% specifies the number of columns. This allows for large 
% passwords/keys/seeds (of non-prime length) to be formatted over several
% lines for ease of reading.

% 3) RandomMethod
% A method of generating random numbers to act as indices to pull from
% another list of random numbers(/characters). If method 1 is picked, then
% the output is, Man-In-The-Middle attacks asside, entirely, 100%, truly
% random. If method 2 is picked, then a pseudorandom component is
% introduced, but the result is probably safer from a practical standpoint
% due to the risk associated with Man-In-The-Middle attacks being
% reduced/removed.

% 4) LoopNum
% LoopNum determines, effectively, how many passwords to generate. If you
% wish to find a certain string within an output password, then you may
% have to set this value to be quite large. For the time being, this
% number cannot be larger than 1024.

% 5) StrToFind
% StrToFind is a string to be found in output passwords. Mainly used for
% shits-and-giggles (you might as well just randomly replace a few bits
% by hand if you really want a string to appear, especially when they get
% fairly long and the odds of generating a password with such a string
% become exceedingly low).

%%

% IOTA seed
AllowedChars = {'A-Z','9'};
KeypassDim = [9,9];
RandomMethod = 2;
LoopNum = 1024;
StrToFind = 'IOTA';

%%

% Use like this when you do not wish to have the optional input 'StrToFind'
AoK = RandKeyGen(AllowedChars,KeypassDim,RandomMethod,LoopNum);

%%

% % Use like this with the optional input 'StrToFind'
% [AoK,ALERT] = RandKeyGen(AllowedChars,KeypassDim,RandomMethod,LoopNum,StrToFind);

% Type AoK{ALERT} into the Command Window to print all keys containing the
% desired string.