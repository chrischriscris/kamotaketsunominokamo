all: kamotake/bin/glucose

kamotake/bin/glucose: glucose/simp/Makefile
	cd glucose/simp && make glucose
	cd ../..
	mv glucose/simp/glucose kamotake/bin/glucose

clean:
	rm -rf kamotake/bin/glucose
