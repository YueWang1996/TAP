BOOGIEOPT:=/z3opt:smt.RELEVANCY=0 /z3opt:smt.CASE_SPLIT=0 /errorLimit:1
BUILD=build
COMMON:=Common
TAP=AbstractPlatform
SANCTUM_MMU:=Sanctum/MMU
SANCTUM_CPU:=Sanctum/CPU
SANCTUM_HOST:=Sanctum/Host
SANCTUM_COMMON:=Sanctum/Common
SANCTUM_MONITOR:=Sanctum/Monitor
SANCTUM_UTILS:=Sanctum/Utils

COMMON_FILES=$(COMMON)/Types.bpl $(COMMON)/Cache.bpl
SANCTUM_COMMON_FILES=$(SANCTUM_COMMON)/Machine.bpl \
		     $(SANCTUM_COMMON)/Prelude.bpl \
		     $(SANCTUM_COMMON)/Types.bpl
SANCTUM_UTIL_FILES=$(SANCTUM_UTILS)/Utils.bpl
SANCTUM_MMU_FILES=$(SANCTUM_MMU)/MMU.bpl $(SANCTUM_MMU)/Common/Common.bpl
SANCTUM_CPU_FILES=$(SANCTUM_CPU)/CPU.bpl
ABSTRACT_RISCV_MMU=$(SANCTUM_MMU_FILES) $(SANCTUM_MMU)/AbstractSanctumMMU/AbstractRISCVMMU/AbstractRISCVMMU.bpl
ABSTRACT_SANCTUM_MMU=$(ABSTRACT_RISCV_MMU) $(SANCTUM_MMU)/AbstractSanctumMMU/AbstractSanctumMMU.bpl
SANCTUM_MONITOR_FILES=$(SANCTUM_MONITOR)/Monitor.bpl
SANCTUM_FILES = $(SANCTUM_COMMON_FILES) $(SANCTUM_UTIL_FILES) $(ABSTRACT_SANCTUM_MMU) $(SANCTUM_CPU_FILES) $(SANCTUM_MONITOR_FILES)

SGX_FILES = SGX/Hardware/sgx.bpl

TAP_FILES = $(TAP)/CPU.bpl $(TAP)/Types.bpl

SANCTUM_REFINEMENT_PROOF_TARGET=$(BUILD)/SanctumRefinementProof.xml
SGX_REFINEMENT_PROOF_TARGET=$(BUILD)/SGXRefinementProof.xml

all: $(SANCTUM_REFINEMENT_PROOF_TARGET) $(SGX_REFINEMENT_PROOF_TARGET)

sanctum: $(SANCTUM_REFINEMENT_PROOF_TARGET)

sgx: $(SGX_REFINEMENT_PROOF_TARGET)

$(SANCTUM_REFINEMENT_PROOF_TARGET):
	$(BOOGIE) $(BOOGIEOPT) $(COMMON_FILES) $(SANCTUM_FILES) $(TAP_FILES) SanctumRefinementProof.bpl

$(SGX_REFINEMENT_PROOF_TARGET):
	$(BOOGIE) $(COMMON_FILES) $(SGX_FILES) $(TAP_FILES) SGXRefinementProof.bpl

clean:
	rm -f $(BUILD)/*.xml

.PHONY: clean
