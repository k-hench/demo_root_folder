/* Our raw data file*/
Channel
	.fromPath("data_file.txt")
	.set{ data_channel }

/* The populations grouped with an index*/
Channel
	.from( [[1, "popA"], [2, "popB"], [3, "popC"]] )
	.into{ pop_channel1; pop_channel2 }

/* The two different averaging sensitivities*/
Channel
	.from( ["10kb", "50kb"] )
	.set{ span_channel }

data_channel                 /* start with the raw data */
	.combine( pop_channel1 )  /* add pop1 to data */
	.combine( pop_channel2 )  /* cross with pop2 */
	.filter{ it[1] < it[3] }  /* discad the upper triangle of the cross */
	.map{ it[0,2,4]}          /* select only data & pops (remove indexes) */
	.combine( span_channel )  /* cross with sensitivities */
	.set{ pairs_channel }     /* name output channel */

process run_pairewise {
	publishDir "output/${span}", mode: 'copy'

	input:
	set file( data ), val( pop1 ), val( pop2 ), val( span ) from pairs_channel

	output:
	file( "step1.${pop1}-${pop2}.${span}.txt" ) into step1_channel

	script:
	"""
	cat ${data} > step1.${pop1}-${pop2}.${span}.txt                 # check data content
	echo "${pop1} vs. ${pop2}" >> step1.${pop1}-${pop2}.${span}.txt # run pairewise 'fst'
	echo "-- ${span} --" >> step1.${pop1}-${pop2}.${span}.txt       # running average
	"""
}

