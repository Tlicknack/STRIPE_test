#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/configfile

BWAdir=${BASEDIR}/${EXPERIMENT}/BWAdir

mkdir ${BWAdir}
mkdir ${BWAdir}/${GENOME_DIR}
ln -s ${BASEDIR}/${GENOME_DIR}/${GENOME_FILE} ${BWAdir}/${GENOME_DIR}/${GENOME_FILE}


cd ${BWAdir}

echo "Indexing the Paramecium genome using bwa ..."
echo "bwa index ${GENOME_DIR}/${GENOME_FILE}"
${BWA}    index ${GENOME_DIR}/${GENOME_FILE}

echo "Starting alignments ..."
for fq in ${fastqDIR}/*_trno_tagdusted_READ?.fq;
do

        echo "bwa aln -t ${THREADS} -n 3 ${GENOME_DIR}/${GENOME_FILE} -f $(basename ${fq} .fq).sai ${fq}"
        ${BWA}    aln -t ${THREADS} -n 3 ${GENOME_DIR}/${GENOME_FILE} -f $(basename ${fq} .fq).sai ${fq}

done

#NEW Alignment
bwa mem -t ${THREADS} ${GENOME_DIR}/${GENOME_FILE} -M ${BASEDIR}/${EXPERIMENT}/fastq/PjSTRIPE_rep1_trno_tagdusted_READ1.fq ${BASEDIR}/${EXPERIMENT}/fastq/PjSTRIPE_rep1_trno_tagdusted_READ2.fq > tmp1

bwa mem -t ${THREADS} ${GENOME_DIR}/${GENOME_FILE} -M ${BASEDIR}/${EXPERIMENT}/fastq/PjSTRIPE_rep2_trno_tagdusted_READ1.fq ${BASEDIR}/${EXPERIMENT}/fastq/PjSTRIPE_rep2_trno_tagdusted_READ2.fq > tmp2

bwa mem -t ${THREADS} ${GENOME_DIR}/${GENOME_FILE} -M ${BASEDIR}/${EXPERIMENT}/fastq/PjSTRIPE_rep3_trno_tagdusted_READ1.fq ${BASEDIR}/${EXPERIMENT}/fastq/PjSTRIPE_rep3_trno_tagdusted_READ2.fq > tmp3

 #then cat this into --> 
cat tmp1 | samtools view -uS - | samtools sort -O BAM - > PjSTRIPE_rep1_sorted.bam
cat tmp2 | samtools view -uS - | samtools sort -O BAM - > PjSTRIPE_rep2_sorted.bam
cat tmp3 | samtools view -uS - | samtools sort -O BAM - > PjSTRIPE_rep3_sorted.bam

for fq in ${fastqDIR}/*_trno_tagdusted_READ1.fq; 
do

echo "samtools index -b $(basename $fq _trno_tagdusted_READ1.fq)_sorted.bam "
${SAMTOOLS} index -b $(basename $fq _trno_tagdusted_READ1.fq)_sorted.bam

#indexing makes them .bam.bai

#.. post-alignment filtering for proper alignments and MAPQ >= 10:

echo "samtools view -f 2 -q 10 -u $(basename $fq _trno_tagdusted_READ1.fq)_sorted.bam | samtools    sort -O BAM -@ 10 - > $(basename $fq _trno_tagdusted_READ1.fq)_filtered.bam"
${SAMTOOLS}    view -f 2 -q 10 -u $(basename $fq _trno_tagdusted_READ1.fq)_sorted.bam | ${SAMTOOLS} sort -O BAM -@ 10 - > $(basename $fq _trno_tagdusted_READ1.fq)_filtered.bam

echo "samtools index -b $(basename $fq _trno_tagdusted_READ1.fq)_filtered.bam"
${SAMTOOLS}    index -b $(basename $fq _trno_tagdusted_READ1.fq)_filtered.bam

#indexing to filtered.bam.bai

done

