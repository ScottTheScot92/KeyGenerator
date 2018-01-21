function [AoK,ALERT] = RandKeyGen(AllowedChars,KeypassDim,RandomMethod,LoopNum,StrToFind)
% Author name: Scott Lockerbie Todd
% Email: scott@todd.science
%
% Random key/password/seed generator.
%   This function takes as input:
%
%   1) The characters allowed to appear in the output. This input is
%   'AllowedChars' and must be input as a cell containing strings. For
%   example, declaring: AllowedChars = {'A-Z','a-z','0-9'} will mean that
%   the ouput password can contain any alphanumeric character (the numbers
%   0-9, and the letters A-Z, regardless of case); no characters other than
%   these will be present in the password. As another example
%   Declaring: AllowedChars = {'A-C','G','4-7','!'} will result in the
%   output password only containing the letters 'A', 'B', 'C', 'G', the
%   numbers '4', '5', '6', '7', and the symbol '!'.
%
%   2) Specification on the length of the output to be generated; for ease
%   of reading, the output can be arranged into an array, and so the length
%   of the output is specificed by a number of rows and columns. The inputs
%   for the number of rows and columns of the ouput password are given,
%   respectively, by the first and last elements of the input 'KeypassDim'.
%
%   3) A method of generating random numbers to act as indices to pull from
%   another list of random numbers(/characters). If method 1 is picked,
%   then the output is, Man-In-The-Middle attacks asside, entirely, 100%,
%   truly random. If method 2 is picked, then a pseudorandom component is
%   introduced, but the result is probably safer from a practical
%   standpoint due to the risk associated with Man-In-The-Middle attacks
%   being reduced/removed.
%
%   4) The number of keys/passwords/seeds to generate. The input to decide
%   how many of these are generated is 'LoopNum'. As of right now, the
%   largest input that this can take is '1024' due to restrictions with the
%   API.
%
%   5) OPTIONAL INPUT. Specification of a string to be present in the
%   output password. This is input as 'StrToFind' and must be formatted as
%   a string. For example, declaring: StrToFind = 'HELLO' will yield an
%   output indicating which elements of the output AoK (if any) possess the
%   string 'HELLO' in it. This is mainly for shits-and-giggles.
%
%   This function outputs:
%
%   1) An array containing a number (LoopNum) of keys/passwords/seeds of
%   the desired length (KeypassSize). This array is AoK (Array
%   of Keys).
%
%   2) OPTIONAL OUTPUT. The elements of AoK that contain the desired string
%   (StrToFind) that can be supplied as an optional input. Once the script
%   has successfully run, "AoK{ALERT}" will output all cells containing the
%   desired string.


% FUNCTION STARTS HERE


% PART I: Generate a truly random string of characters to be used in
% password/key/seed generation


% Create an empty cell of dimensions equal to that of 'AllowedChars', where
% the dimension is given by how many input strings are present in
% 'AllowedChars'. This empty cell will be filled later with the decimal
% ASCII labels corresponding to each input character that is allowed.

AllowedCharsASCII = cell(1,numel(AllowedChars));

% Iterate through each element (string) of AllowedChars and determine if
% the current index contains a single character (such as 'A'), or a range
% of characters (suc as 'A-Z').

% IF a single character is present in the AllowedChars cell:
% THEN Do nothing to AllowedChars.

% IF a range is present in AllowedChars (three characters; a start to the
% range, a hyphen, and an end to the range. e.g. something like '0-9' ):
% THEN Replace the range string (e.g. '0-9') with every character included
% in the range (e.g. '0', '1', '2', '3', '4', '5', '6', '7', '8', '9').

% In essence we are 'unpacking' the cell 'AllowedChars'.

% In either case, keep hold of the ASCII characters that correspond to the
% expanded AllowedChars list (these are stored in the cell
% AllowedCharsASCII).

for i = 1:numel(AllowedChars)
    
    % This part of the if statement corresponds to a range (such as '0-9'
    % or 'A-Z') being present in the input.
    
    if numel(AllowedChars{i}) == 3
        
        % Performing mathematical operations on a string results in the
        % string being treated as its corresponding ASCII characters.
        % Multiply the start and end characters of a range (i.e. '0' and
        % '9' in the range '0-9') by 1 to find their corresponding ASCII
        % characters, and then create a vector of sequential numbers with
        % these ASCII values as the terminating values. This 'unpacks' a
        % string like 'A-Z' into a matrix of ASCII characters that
        % correspond to all upper case letters between A and Z (inclusive).
        
        ExpandedRangeASCII = (AllowedChars{i}(1)*1):(AllowedChars{i}(3)*1);
                
        % Fill the corresponding ASCII cell.
        
        AllowedCharsASCII{i} = ExpandedRangeASCII;
        
    % This next part of the if statement corresponds to a single character
    % being present in the input ('!', or '9', etc).
        
    elseif numel(AllowedChars{i}) == 1
        
        % As per above, however for a single element string no range needs
        % to be unpacked. The element is merely turned into its
        % corresponding ASCII symbol and filled into the ASCII cell.
        % Nothing needs to be done to this element in the original
        % AllowedChars cell (no unpacking is required).
        
        ExpandedRangeASCII = AllowedChars{i}(1)*1;
        AllowedCharsASCII{i} = ExpandedRangeASCII;
        
    end
    
end

% At this point we no longer need the AllowedChars or AllowedCharsASCII
% data to be stored in a cell. For our purposes, a vector will be
% appropriate.

% Turn the ASCII cell into a vector of characters (essentially, unpack each
% element of the cell now).

AllowedCharsASCII = [AllowedCharsASCII{:}];

% Obtain a random string of characters from the ANU quantum random number
% generator. To maximise the number of characters that we can pull using
% the API, we are going to generate hex16 characters of maximum block size
% (1024), and generate as many as possible (1024). Each hex16 block is
% (apparently) 2 characters long, so this is a total of 2*1024*1024
% (2097152) characters. We then take this fuck-huge hexadecimal string and,
% based on the ASCII characters to be used (as determined above in
% AllowedCharsASCII), chop the string up into chunks of a given length. The
% lengths that we chop the string up into are such that when converted from
% hexadecimal to decimal, and then from decimal to ASCII, the allowed ASCII
% characters can all appear.

% For example, standard ASCII contains 256 characters. In hexadecimal only
% two characters are required to totally account for 256 possibilities
% (16*16=256). Therefore, the string of 2*1024*1024 (2097152) hexadecimal
% characters can be broken up into blocks of 2 (1024*1024=1048576 blocks of
% 2); each block of 2 hexadecimal characters can be converted to decimal,
% and each decimal number can be mapped one-to-one to every standard ASCII
% character. In this way, we are able to generate a string of 1048576 ASCII
% characters.

% The link for the ANU quantum random number generator goes here. This
% could be replaced by another source if desired; just make sure that it's
% formatted as a string.

RandomNumberAPI = 'https://qrng.anu.edu.au/API/jsonI.php?length=1024&type=hex16&size=1024';

% Call the API.

ObtainRandomNumbers = webread(RandomNumberAPI);

% Extract the hexadecimal numbers from the API data. The cell entry that
% contains the data is called... well, 'data'.

RandomNumbers = (ObtainRandomNumbers.data)';

% Unpack the cell data into a vector.

RandomNumbersString = [RandomNumbers{:}];

% Determine how many elements are in the string of random numbers. This was
% fixed in the API call, however this could be changed if one desired. The
% reason we're doing this is to make sure that the dimensions all work out
% later on when we reshape the string of random numbers (and we reshape
% so that the command 'hex2dec' doesn't turn a ~1-million digit long
% hexadecimal number into a single decimal number; instead it converts
% ~1-million/n hexadecimal numbers all of length 'n' into decimal numbers).

NumberOfRandomNumbers = numel(RandomNumbersString);

% Determine the smallest hexadecimal chunk size required to completely
% account for all characters that are allowed to appear in the output. The
% condition here is 16^(chunk size) >= (max ASCII code of symbols chosen).

RandomNumberStringReshapeDim = ceil(log(max(AllowedCharsASCII))/log(16));

% If the total string length isn't exactly divisible by the block size
% required, then trim the last few digits off to make it divisible. This
% way we can use the reshape command on the string, making it easy to
% convert each chunk from hexadecimal to decimal. This should not harm the
% random nature of the data as we are not preferentially selecting certain
% digits to remove; trimming the last few digits off of the end of the
% string should be no different than had we merely requested a smaller set
% of digits from the API in the first place.

RandomNumbersToUse = RandomNumbersString(1:(NumberOfRandomNumbers-mod(NumberOfRandomNumbers,RandomNumberStringReshapeDim)));

% Reshape that bitch.

RandomNumbersArray = reshape(RandomNumbersToUse,(numel(RandomNumbersToUse)/RandomNumberStringReshapeDim),RandomNumberStringReshapeDim);

% Convert each block from hexadecimal to decimal. This yields us a string
% of random numbers that correspond to ASCII characters, however, depending
% on which characters we have specified as being allowed in AllowedChars,
% not all of these characters (in fact, in all likelihood, only a small
% fraction of these characters) will be valid for our output.

RandomNumbersArrayASCII = (hex2dec(RandomNumbersArray))';

% Create a vector of zeroes that we will populate with 1s to build a
% logical 'mask'. This will let us remove all of the characters that are
% not allowed from the string. Note, this should NOT spoil the random
% properties of a truly random random-number generator, because every
% individual character should be generated with as much liklihood as any
% other, and removing every instance of one type of character will not
% change the relative distribution of remaining characters in the final
% string.

% Further note that creating the 'LocationOfAllowedChars' vector with the
% 'zeros' function eventually has the result that we are unable to include
% the ASCII character represented by 0 in the final string. This is
% probably okay, because the ASCII character corresponding to 0 is
% non-standard and I can't imagine any case in which you'd want to use it
% in a password (hell, I doubt you're able to).

LocationOfAllowedChars = zeros(1,numel(RandomNumbersArrayASCII));

% Next, iterate through every allowed ASCII character. Create a temporary
% vector that contains a '1' at positions that correspond to those
% positions in the array of random characters that contain an allowed
% ASCII character. The temporary vector contains zeros everywhere else
% (where there isn't an allowed ASCII character in the corresponding
% position in the array of random characters).

for i = AllowedCharsASCII
    
    MaskForCurrentChar = RandomNumbersArrayASCII == i;
    
    % Add this 'logical mask' to the LocationOfAllowedChars vector and then
    % continue through the loop until LocationOfAllowedChars eventually
    % contains '1's wherever there is an allowed character in the array of
    % random characters, and '0's everywhere else.
    
    LocationOfAllowedChars = LocationOfAllowedChars + MaskForCurrentChar;
    
end

% Pick out the allowed characters from the array of random characters by
% applying the mask to it (elementwise multiplication keeps the allowed
% characters (multiplication by 1) and removes the disallowed characters
% (multiplication by 0)).

LogicalListOfChars = LocationOfAllowedChars.*RandomNumbersArrayASCII;

% Remove all instances of '0' to yield an array that only contains allowed
% ASCII characters.

ListOfAllowedChars = LogicalListOfChars(LogicalListOfChars~=0);

% Use the 'char' command to turn the decimal representation of the ASCII
% characters into the actual desired characters. This completes our journey
% into generating a truly random string of desired digits to be used in
% generating keys/passwords/seeds.

RandomString = char(ListOfAllowedChars);

% If the first method of obtaining random numbers to pick from RandomString
% is to be used, then RandomString is to be shortened slightly to aid in
% reshaping later. If the second method is to be used, then RandomString is
% fine as is.

if RandomMethod == 1

    % Shorten the list of allowed characters to the closest power of 16
    % less than the current length. Again, note that this should not harm
    % the random nature of the data as we are not preferentially selecting
    % certain digits to remove; trimming the last few digits off of the end
    % of the string should be no different than had we merely requested a
    % smaller set of digits from the API in the first place.

    RandomStringShorterLength = 16^(floor(log(numel(RandomString))/log(16)));

    RandomString = RandomString(1:RandomStringShorterLength);
    
end


% PART II: Quantum boogaloo!

% This next part takes RandomString, and then randomly picks elements from
% it to generate the final passwords/keys/seeds desired. There are two ways
% to do it as of right now (if you know of another truly random source of
% random numbers, akin to the ANU quantum random number generator, please
% contact me (my email is at the top of the function). I'd like to include
% a second API call to another source of true random numbers in here if
% possible).
%
%
% First method: Use the ANU API a second time to generate positions in
% RandomString to be used in building the passwords/seeds/keys.
% 
% Benefits: Assuming the connection from ANU to your computer isn't
% hijacked (you don't get Man-In-The-Middle attacked) then every step of
% the process to build your passwords/keys/seeds is entirely random (no
% pseudorandom nonesense). This is pleasing to me from a mathematical
% standpoint.
% 
% Detriments: If a third party does hijack the connection from ANU to your
% computer (or ANU itself gets hijacked), then this party would now be
% supplying your 'random' numbers and, if they had access to this function,
% would very easily be able to reverse engineer the passwords/seeds/keys
% that you generated.
%
%
% Second method: Use MATLAB's inbuild random number generator to generate
% positions in RandomString to build the passwords/seeds/keys.
%
% Benefits: Some aspect of the code runs on-site, meaning that somebody
% can't entirely Man-In-The-Middle attack you by intercepting the API-calls
% in both PART I and PART II in order to supply you with a list of their
% own 'random' numbers. If somebody did manage to supply you with their own
% list of 'random' numbers in the API call from PART I, they'd still have
% to figure out how your MATLAB random number generator had been seeded in
% order to be able to reverse engineer your code.
%
% Detriments: Introduces a pseudorandom aspect to the whole process. Given
% that the random numbers in PART I are generated in a huge number and
% they appear to be truly random, this probably isn't actually a real
% concern, however. All in all, this method is probably the most secure
% (but not as cool).

% Extract the number of rows and columns that are to be used in formatting
% the output from KeypassDim. Also, multiply these two numbers together to
% find the total length of the output password/key/seed.

KeypassRows = KeypassDim(1);
KeypassCols = KeypassDim(2);
KeypassSize = KeypassRows*KeypassCols;

% Create an empty cell to store keys in (Array of Keys).

AoK = cell(1,LoopNum);

if nargin == 5 && nargout == 2
    
    % Create an alert to inform the user if their desired string was found
    % in any of the output keys.
    
    ALERT = [];
    
end

% If the first method of random number generation (calling the ANU API) is
% to be used again, then the API must be called again. Else, if the second
% method of random number generation is being used, then merely generate a
% bunch of random numbers using MATLAB's 'randi' function.

if RandomMethod == 1

    % Generate random positions to pull from in the string of random numbers
    % that we obtained in PART I above. Here we shall call on the ANU quantum
    % random number generator (again) to do so. We could just as well pull
    % characters from 'RandomString' in chunks of the desired
    % password/key/seed size, but there's no harm in introducing more
    % randomness. To see why, consider the case in which we just pull chunks of
    % the desired length out of 'RandomString' and use these as our
    % passwords/keys/seeds; if we do this, then all passwords/keys/seeds
    % generated herein will just be sub-strings of 'RandomString'. If somebody
    % somehow intercepted the API call from PART I and figured out
    % what characters you were using (i.e. they determined 'RandomString'),
    % they would only have to brute-force guess substrings of 'RandomString' to
    % obtain the passwords generated here. If we generate ANOTHER random string
    % that tells us which elements of 'RandomString' to pull out to generate a
    % password/key/seed, then, as well as scrambling the order of
    % 'RandomString', it's also possible that the same element will be
    % picked multiple times from 'RandomString', making it impossible to guess
    % a password by only searching for substrings of 'RandomString'. Of course,
    % this point is moot if they also intercept the second API call, however,
    % adding in additional difficulty to make life annoying for potential
    % ne'er-do-wells doesn't seem like a bad idea in my opinion.

    % BlockSizeToRequest determines the blocksize that should be requested to
    % make sure every hexidecimal number corresponds to a position in
    % RandomString (which is guaranteed, as RandomString was trimmed to be
    % exactly a power-of-16 in length).

    BlockSizeToRequest = ceil((log(RandomStringShorterLength)/log(16))/2);

    % Create the ANU quantum random number API call to generate enough
    % multiples of the correct block length to cover the total number of runs.

    SelectionAPI = ['https://qrng.anu.edu.au/API/jsonI.php?length=',string(LoopNum),'&type=hex16&size=',string(BlockSizeToRequest*KeypassSize)];
    SelectionAPI = [SelectionAPI{:}];

    % Call the API.

    WhereToSelect = webread(SelectionAPI);

    % Extract the hexadecimal numbers from the API data. The cell entry that
    % contains the data is, as in PART I, called 'data'.

    RandomLocations = (WhereToSelect.data)';
    
elseif RandomMethod == 2
    
    % To generate random positions in RandomString using MATLAB, first
    % preallocate an empty array to store random numbers for each loop in.
   
    RandomLocations = cell(1,LoopNum);
    
    % Now generate a bunch of random numbers to be used as position-indices
    % to grab the random characters out of RandomString. Generate
    % KeypassSize-many random numbers for the total number of loops to be
    % performed.
    
    for LoopRandNums = 1:LoopNum
       
        
        % Generate random integers from 1 up to the length of RandomString
        % (i.e. numbers corresponding to positions in RandomString).
        % Generate enough of them to populate the passwords/keys/seeds with
        % the length specified.
        
        RandomLocationsToStore = randi(numel(RandomString),1,KeypassSize);
        RandomLocations{LoopRandNums} = RandomLocationsToStore;
        
    end
    
end

% Use the RandomLocations to pick random characters out of RandomString. Do
% this for the desired number of passwords/keys/seeds.

for q = 1:LoopNum
         
    % Assign a blank array to become the key.
    
    EmptyKey = cell(1,KeypassSize);
    
    % Obtain the random positions for this iteration of the loop.
    
    ThisLoopSelection = RandomLocations{q};
    
    % If using the first method of random number generation (ANU API), some
    % stuff needs to be done to make the random numbers obtained from ANU
    % correspond to positions in RandomString.
    
    if RandomMethod == 1
    
        % Reshape such that when hex2dec is used, the numbers it acts on
        % are of the correct blocksize.

        ThisLoopSelection = reshape(ThisLoopSelection,KeypassSize,(2*BlockSizeToRequest));

        % Perform hex2dec to turn all of the hexadecimal numbers into
        % decimal numbers which can then be used as position indices for
        % RandomString.

        ThisLoopSelection = hex2dec(ThisLoopSelection);

        % Because the minimum block size is 2 characters long in the API
        % call, if RandomString has a length that is an odd power of 16,
        % many of the numbers contained in ThisLoopSelection will be larger
        % than any position in RandomString (as ThisLoopSelection has even
        % powers of 16 contained within it). Performing modular arithmetic
        % makes all numbers contained within ThisLoopSelection fall between
        % 0 and numel(RandomString)-1 (bijective to all numbers between 1
        % and numel(RandomString)).

        ThisLoopSelection = mod(ThisLoopSelection,RandomStringShorterLength);

        % Plus 1 to every element in ThisLoopSelection so that every
        % element of ThisLoopSelection is contained within the set
        % {1,2,...,RandomStringLength}, instead of the set
        % {0,1,...,(RandomStringLength-1)}.

        ThisLoopSelection = ThisLoopSelection + 1;
    
    end
    
    for i = 1:KeypassSize
        
        % Fill the empty key with random characters from RandomString. The
        % random characters are selected by picking elements from
        % RandomString that are at the position specified by
        % ThisLoopSelection.
        
        EmptyKey{i} = RandomString(ThisLoopSelection(i));
        
    end
    
    % Reshape the key.
    
    EmptyKey = reshape(EmptyKey,KeypassRows,KeypassCols);
    
    % Take transpose of the matrix key so that when displayed as a string, 
    % the matrix reads in a first left-to-right, then top-to-bottom
    % fashion.
    
    KeyArray = EmptyKey';
    
    % Print key string (linear).
    
    KeyLinear=[KeyArray{1:KeypassCols,1:KeypassRows}];
    
    if nargin == 5 && nargout == 2
        
        % Check for the presence of the desired string.
        
        StringAlert = contains(KeyLinear,StrToFind);
        
        if StringAlert == 0
            
        elseif StringAlert == 1
            
            ALERT = [ALERT,q];
            
        else
          
                       
        end
        
    end
    
    % Print string in an array that has dimensions of KeypassRows x
    % KeypassCols.
    
    KeyArray = reshape(KeyLinear,KeypassCols,KeypassRows)';
    
    % Store this string-array in the in Array of Keys.
    
    AoK{q} = KeyArray;
    
end

% Tell the user if the desired string was found or not.

if nargin == 5 && nargout == 2
    
    if isempty(ALERT)
        
        disp([StrToFind ' not found.'])
        
    else
        
        disp([StrToFind ' found in the following arrays:'])
        disp(ALERT)           
       
    end
    
end

end