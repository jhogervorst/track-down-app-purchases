# Track Down App Purchases v0.1.1

Shell script to list all iOS apps in your iTunes Library, showing which Apple ID was used to purchase each app.

## Installation

### Wget Installation

	$ wget https://raw.github.com/jhogervorst/track-down-app-purchases/master/track-down-app-purchases.sh
	$ chmod +x track-down-app-purchases.sh

### Manual Installation

1. [Download](https://github.com/jhogervorst/track-down-app-purchases/archive/v0.1.1.zip) and extract the ZIP file containing the script.
2. Open a Terminal window and navigate to the directory of the extracted ZIP (using `cd`).
3. Execute `chmod +x track-down-app-purchases.sh` to allow the script to run on your Mac.

## Usage & Example

	$ ./track-down-app-purchases.sh
	
	Path to iTunes Library [~/Music/iTunes]:
	
	------------------------------ | -------------- | ------------------------------
	App Name                       | Bundle Name    | Apple ID                      
	------------------------------ | -------------- | ------------------------------
	Angry Birds Seasons            | Angry Birds    | my_apple_id@me.com            
	Dropbox                        | Dropbox        | my_apple_id@me.com            
	Facebook                       | Facebook       | my_apple_id@me.com            
	iBooks                         |                | another_apple_id@me.com       
	Skype for iPhone               | Skype          | my_apple_id@me.com            
	Tiny Wings                     |                | my_apple_id@me.com            
	Twitter                        | Twitter        | my_apple_id@me.com            
	YouTube                        | YouTube        | my_apple_id@me.com            
	------------------------------ | -------------- | ------------------------------

## See Also

Looking for a script that works with **audio, video, or books** in your iTunes Library? Check out Doug's AppleScript [Track Down Purchases](http://dougscripts.com/449)!

## Compatibility

This script has been tested with iTunes 11 and Xcode 5 on Mac OS X Mountain Lion. Xcode is not required, but having the Command Line Tools [installed](https://developer.apple.com/support/xcode/) might improve the working of this script.

## License

This script is licensed under MIT license. See [LICENSE](LICENSE) for details.