from vcf.parser import _Format
import numpy as np

REVERSE_COMPLIMENT = {"A": "T", "T": "A", "G": "C", "C": "G"}


def extract_alleles_from_snp_string(snp_string):
    """
    Splits SNP string into tuple of individual alleles

    Args: snp_string (string): allele string of the format
        [T/C] or [G/C]

    Returns:
         allele1 (string), allele2 (string)
    """
    (allele1, allele2) = snp_string[1:4].split("/")
    assert allele1 in "ATGC"
    assert allele2 in "ATGC"
    return allele1, allele2


def normalize_alleles_by_strand(snp_string):
    """
    Splits SNP string into tuple of individual alleles and
    gets takes the reverse compliment to match strand 1

    Args: snp_string (string): allele string of the format
        [T/C] or [G/C]

    Returns:
         allele1 (string), allele2 (string)
    """
    # get alleles as tuple
    allele1, allele2 = extract_alleles_from_snp_string(snp_string)
    # get reverse compliment of bases and return
    return REVERSE_COMPLIMENT[allele1], REVERSE_COMPLIMENT[allele2]


class BAlleleFreqFormat(object):
    """
    Generate b allele frequency format information for VCF
    """
    def __init__(self, logger, b_allele_freq):
        self._b_allele_freq = b_allele_freq
        self._logger = logger

    @staticmethod
    def get_id():
        return "BAF"

    @staticmethod
    def get_description():
        return "B Allele Frequency"

    @staticmethod
    def get_format_obj():
        # arguments should be: ['id', 'num', 'type', 'desc']
        return _Format(BAlleleFreqFormat.get_id(), 1, "Float", BAlleleFreqFormat.get_description())

    def generate_sample_format_info(self, bpm_records, vcf_record, sample_name):
        """
        Get the sample B allele frequency

        Args:

        Returns:
            float: B allele frequency
        """
        # if we have more than 1 BPMRecord, need to merge
        b_allele_freq_list = []
        if len(bpm_records) > 1:
            # if we have more than 1 alt allele, return missing
            if len(vcf_record.ALT) > 1:
                return "."
            for i in range(len(bpm_records)):
                snp = bpm_records[i].snp
                strand = bpm_records[i].ref_strand

                idx = bpm_records[i].index_num
                b_allele_freq = self._b_allele_freq[idx]
                # if  second strand, normalize strand
                if strand == 1:
                    allele1, allele2 = extract_alleles_from_snp_string(snp)
                else:
                    allele1, allele2 = normalize_alleles_by_strand(snp)

                # normalize to reference allele
                ref_allele = vcf_record.REF
                # if allele1 is reference, then B allele is correct
                if allele1 == ref_allele:
                    b_allele_freq_list.append(b_allele_freq)
                # if allele2 is reference, then we need to do 1-freq
                elif allele2 == ref_allele:
                    b_allele_freq_list.append(1. - b_allele_freq)

                #chrom = bpm_records[i].chromosome
                #start_pos = bpm_records[i].pos
                #alt_allele = vcf_record.ALT
                #print("chr: {} pos: {} ref: {} alt: {} snp: {} strand: {} BAF: {}".format(chrom, start_pos, ref_allele, alt_allele, snp, strand, b_allele_freq))

            #print(b_allele_freq_list)

        # otherwise single BPMRecord
        else:
            # if we have a multi-allelic site, return missing
            if len(vcf_record.ALT) > 1:
                return "."
            idx = bpm_records[0].index_num
            b_allele_freq_list.append(self._b_allele_freq[idx])

        # nanmedian ignores NaN values
        final_b_allele_freq = np.nanmedian(b_allele_freq_list)
        if np.isnan(final_b_allele_freq):
            return "."
        else:
            return final_b_allele_freq
