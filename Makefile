all: kamotake/bin/glucose

kamotake/bin/glucose: glucose/simp/Makefile
	cd glucose/simp && make glucose
	cd ../..
	cp glucose/simp/glucose kamotake/bin/glucose
	cp  glucose/simp/glucose kamotake-web/bin/glucose
	rm -rf glucose/simp/glucose

clean:
	rm -rf kamotake/bin/glucose
