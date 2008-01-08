___BUCKING ASSEMBLY README___


About the code:

The bucking assembly language program is written using the 
"Assembly Studio 8X" IDE provided by "Assembly Coder's Zenith" (ACZ), and 
it is written for the TI86 Texas Instruments Graphing Calculator, which 
uses the Z80 micro-processor. Assembly Studio 8X uses the Telemark Assembler 
(TASM), not be be confused with Borland's Turbo Assembler. The source code 
used by Assembly Studio 8X is *NOT* fully compatible with TASM and must be 
slightly modified to compile without the IDE.


About the program:

The bucking program is designed to take inputs such as a tree's length and 
diameter, mill prices, and mill prefered log lengths; and from that, the 
program quickly computes optimal lengths at which to buck the tree into 
logs. 

With additional inputs of mill distances and trucking costs the 
program might also be extended to recommend which mill to use.


Quick Info:

* Language - Assembly Studio 8X, Z80 assembly
* Platform - Texas Instruments TI86 graphing calculator
* Functionality - Compute optimal lengths at which to buck a tree into logs


Changelog:

- version 1.0.4 beta
	- first version to run on the TI86 and successfully compute many
		tree buck lengths accurately
	- nearly complete implementation of the version 1.0.4 bucking
		algorithm, however, the internal iterative search framework
		is buggy and ocassionally returns bad results
	- no user interface, must be reloaded before each run
	
- version 1.5.0 beta
	- complete implementation of the much improved version 1.5.0 bucking
			algorithm
		- massive changes to the iterative search control flow
		* From the algorithm readme:
		- possible log lengths are now stored in an array rather 
		    than being determined mathematically
		- now capable of handling different mills (eg, the framework
		    can now handle *any* possible log length rather than 
		    just multiples of 2 within the boundaries of 16 and 40 
		    feet) 
		    - NOTE: this is not supported by the price and volume 
		        functions yet, they are still constrained to the 
		        16-40' boundaries
		- log priority can now be specified based on position in 
		    the array
		- more robust, not as finnicky regarding loop conditions
	- several bug fixes in the data copy section
	- again, no user interface

- version 2.0.0
	- complete implementation of rudimentary user interface
		- basic functionality works
	- no need to reload before each run
		- program automatically resets volatile data
		
- version 3.0.0
	- user interface received extensive fleshing out
		- start, about, setup, and final display screens 
			implemented
	- statistics, mill, and calculation options are visible to the 
			user but are not yet implemented
	- price checking algorithm rewritten to work better with version
			1.5.0 of the bucking algorithm
		- less code
		- more versatile with price per length rather than 
			price per length-range
		- capable of hooking into the bucking algorithm to 
			increase total program speed
	- log prices and mill prefered lengths can now be changed at runtime
	- this is the first version implementing enough of the planned 
		features to be considered production ready
		
- version 3.0.1
	- user interface improvements
		- 'x' placed after each zero-price log in the data printout
			to designate firewood/non-mill/cull logs
			
- version 3.1.0
	- increased code modularity and cleaned up appearance
		- price, iterator, and volume sections are now separate
			subroutines
		- placed data and all conceptually separate sections of 
			code in separate include files, thus increasing
			the readability of the main bucking algorithm
	
- version (may have missed a couple here)


- version 3.2.0
    - further increased code modularity
        - buck algorithm is now in its own module/function
        - changed the internal naming scheme
        - further separated the advanced subroutines to limit label interferance
    - wrote tamper checker which discourages copying the program from one
        calculator to another

- version 3.3.0
    - massive changes to the graphics functions
        - special menu handling routines added
            - drawing, blanking, message display
        - much of the display text has been consolidated
            - unnecessary spaces removed
    - slimming down of all user interface routines
        - total code is now hundreds of bytes smaller
    - new mill switching routine allows for up to three mills to be saved
        in the calculator at once and switched between
        - new section of the setup routine added to handle mill switching and
            editing

- version 4.0.0
    - this was an unplanned major change to the program
        - ran out of space and needed more in order to add features
        - the bucking calculator now requires helper programs
            - specifically, BuckLP2, once a subroutine, is now an external 
                helper program that enables length and price editing
    - BuckLP2 was optimized to avoid display redraw flicker
    - a tree's bucked volume can now be viewed by pressing the <MORE> key
    - modified the bucking algorithm to handle logs shorter than 16 feet long

- version 5.0.0
    - added statistics tracking
        - wrote special data structure for handling result data
        - rewrote FinDisplay and modified several other routines to use the 
            data structure
        - wrote special BuckStat statistics helper program
        - wrote setup routine that can turn statistics on/off
    - polished up the gui
        - only relevant errors are printed
        - menu options are more consistant
    - fixed bug in volume summing
        - now only logs that have value are considered for the total volume



