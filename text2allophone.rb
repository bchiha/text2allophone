

class Text2allophone

	attr_reader :cmu2sp0256File, :cmuDictFile

	def initialize
		@cmu2sp0256File = 'cmu2sp0.symbols'
		@cmuDictFile = 'cmudict-0.7b'
		@cmuDict = Hash.new	#word -> allophones
		@cmuRef = Hash.new #allophones -> {sp0256 allophone, hex value}
	end

	def loadCmuRefFile
		File.open(@cmu2sp0256File, "r") do |file|
			file.each_line do |line| 
				parts = line.strip.split(' ')
				@cmuRef[parts[0]] = {:text=>parts[1],:hex=>parts[2]}
			end
		end
	end
	
	def loadCmuDictFile
		File.open(@cmuDictFile, "r") do |file|
			file.each_line do |line| 
				if line[0] != ';' 
					parts = line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').strip.split(" ")
					@cmuDict[parts[0]] = parts.last(parts.size-1) #just get the rest
				end
			end
		end
	end

	def translate
		while line = gets
			badWord = []
			printf("TXT> ")
			line.upcase.split(' ').each do |word|
				if @cmuDict.include?(word)
					@cmuDict[word].each do |allophone|
						printf("%s ",@cmuRef[allophone][:text])
					end
					printf(". ")
				else
					badWord << word
				end
			end
			printf("\nHEX> ")
			line.upcase.split(' ').each do |word|
				if @cmuDict.include?(word)
					@cmuDict[word].each do |allophone|
						printf("%s ",@cmuRef[allophone][:hex])
					end
					printf("03 ") #word gap
				end
			end
			if !badWord.empty?
				puts "\nWord(s) '#{badWord.join(",")}' not found in dictionary"
			end
			printf("\n\n")
		end
	end
	
end

t2a = Text2allophone.new

t2a.loadCmuDictFile
t2a.loadCmuRefFile

puts "Type in a sentence to convert...(C-d to exit)\n\n"

t2a.translate

