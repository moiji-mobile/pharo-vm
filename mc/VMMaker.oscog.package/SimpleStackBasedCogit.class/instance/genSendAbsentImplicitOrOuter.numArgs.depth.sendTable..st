bytecode generators
genSendAbsentImplicitOrOuter: selector numArgs: numArgs depth: depth sendTable: sendTable
	<var: #sendTable type: #'sqInt *'>
	| nsSendCache |
	(objectMemory isYoung: selector) ifTrue:
		[hasYoungReferent := true].

	nsSendCache := theIRCs + (NumOopsPerNSC * objectMemory bytesPerOop * indexOfIRC).
	indexOfIRC := indexOfIRC + 1.
	self assert: (objectMemory isInOldSpace: nsSendCache).
	self initializeNSSendCache: nsSendCache selector: selector numArgs: numArgs depth: depth.

	"This leaves the method receiver on the stack, which might not be the implicit receiver.
	 But the lookup trampoline will establish the on-stack receiver once it locates it."
	self marshallAbsentReceiverSendArguments: numArgs.

	"Load the cache last so it is a fixed distance from the call."
	self MoveUniqueCw: nsSendCache R: SendNumArgsReg.
	self CallNewspeakSend: (sendTable at: (numArgs min: NumSendTrampolines - 1)).

	self PushR: ReceiverResultReg.
	^0