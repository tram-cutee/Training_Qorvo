database -open waves -into waves.shm -default -event; 
        probe -create -shm -depth all -database waves -waveform -all -dynamic -memories; 
        probe -create -shm -transaction -assertions -depth all -database waves -waveform; 
        run; 
