@***********************************************************
@ Function:    WT_VoiceFilter
@ Processor:   ARM
@ Description:
@ Implements a 2-pole low-pass filter with resonanance
@
@ Usage: 
@	void WT_VoiceFilter(
@		S_FILTER CONTROL *pFilter,
@		S_WT_FRAME *pWTFrame);
@
@ Copyright 2005 Sonic Network, Inc.
@****************************************************************
@ Revision Control:
@   $Revision: 496 $
@   $Date: 2006-12-11 14:33:26 -0800 (Mon, 11 Dec 2006) $
@****************************************************************
@
@   where:
@	S_FILTER_CONTROL *pFilter
@	PASSED IN: r0
@
@	S_WT_FRAME *pWTFrame
@	PASSED IN: r1
@****************************************************************

	.include	"ARM_synth_constants_gnu.inc"

	.arm
	.text


	.global	WT_VoiceFilter
	

@ Register usage
@ --------------
pFilter	.req	r0
pWTFrame	.req	r1
pBuffer	.req	r2
numSamples	.req	r3

z1	.req	r4
z2	.req	r5
b1	.req	r6
b2	.req	r7
K	.req	r8

tmp0	.req	r1	@ reuse register
tmp1	.req	r9
tmp2	.req	r10


@SaveRegs	RLIST	{r4-r10, lr}
@RestoreRegs	RLIST	{r4-r10, pc}


	.func	WT_VoiceFilter
WT_VoiceFilter:

	STMFD	sp!, {r4-r10, lr}

@
@ Setup passed parameters in their destination registers
@----------------------------------------------------------------

	LDR		pBuffer, [pWTFrame, #m_pAudioBuffer]
	LDR		numSamples, [pWTFrame, #m_numSamples]

	@load state variables from pFilter structure
	LDRSH	z1, [pFilter, #m_z1]
	LDRSH	z2, [pFilter, #m_z2]

	@load coefficients from pWTFrame structure
	LDR		K, [pWTFrame, #m_k]
	LDR		b1, [pWTFrame, #m_b1]
	LDR		b2, [pWTFrame, #m_b2]
	
	RSB	b1, b1, #0						@ b1 = -b1
	RSB	b2, b2, #0						@ b2 = -b2
	MOV	b2, b2, ASR #1					@ b2 = b2 >> 1
	MOV	K, K, ASR #1					@ K = K >> 1

@
@ Start processing
@----------------------------------------------------------------

	LDRSH	tmp0, [pBuffer]					@ fetch sample

FilterLoop:
#ifndef __ARM_ARCH_4__
@	SMULBB	tmp2, z1, b1					@ tmp2 = z1 * -b1
@	SMLABB	tmp2, z2, b2, tmp2				@ tmp2 = (-b1 * z1) + (-b2 * z2)
#else
@	MULS	tmp2, z1, b1
@	MULS	tmp1, z2, b2
@	ADD	tmp2, tmp2, tmp1
#endif

	MOV		z2, z1							@ delay line

#ifndef __ARM_ARCH_4__
@	SMLABB	tmp0, tmp0, K, tmp2				@ tmp1 = (K * x[n]) + (-b1 * z1) + (-b2 * z2)
#else
@	MULS	tmp0, tmp0, K
@	ADD	tmp0, tmp0, tmp2
#endif
	LDRSH	tmp1, [pBuffer, #NEXT_OUTPUT_PCM]	@ fetch next sample
	
	MOV		z1, tmp0, ASR #14				@ shift result to low word
	STRH	z1, [pBuffer], #NEXT_OUTPUT_PCM	@ write back to buffer

#ifndef __ARM_ARCH_4__
@	SMULBB	tmp2, z1, b1					@ tmp2 = z1 * -b1
#else
@	MULS	tmp2, z1, b1
#endif
	
	SUBS	numSamples, numSamples, #2		@ unroll loop once

#ifndef __ARM_ARCH_4__
@	SMLABB	tmp2, z2, b2, tmp2				@ tmp2 = (-b1 * z1) + (-b2 * z2)

@	SMLABB	tmp1, tmp1, K, tmp2				@ tmp1 = (K * x[n]) + (-b1 * z1) + (-b2 * z2)
#else
@	MULS	tmp0, z2, b2
@	ADD	tmp2, tmp0, tmp2
@	MULS	tmp1, tmp1, K
@	ADD	tmp1, tmp1, tmp2
#endif

	MOV		z2, z1							@ delay line

	MOV		z1, tmp1, ASR #14				@ shift result to low word
	
	LDRGTSH	tmp0, [pBuffer, #NEXT_OUTPUT_PCM]	@ fetch next sample

	STRH	z1, [pBuffer], #NEXT_OUTPUT_PCM	@ write back to buffer

	BGT		FilterLoop
@ save z terms
@----------------------------------------------------------------

	STRH	z1, [pFilter, #m_z1]
	STRH	z2, [pFilter, #m_z2]

@ Return to calling function
@----------------------------------------------------------------

	LDMFD	sp!,{r4-r10, lr}
	BX		lr

	.endfunc
	.end

