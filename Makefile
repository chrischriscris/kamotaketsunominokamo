all: sat-planner/bin/glucose

sat-planner/bin/glucose: glucose/simp/Makefile
	cd glucose/simp && make glucose
	cd ../..
	mv glucose/simp/glucose sat-planner/bin/glucose

clean:
	rm -rf sat-planner/bin/glucose
