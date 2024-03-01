const LOOKUP_PATH = artifact"kociemba_lookup"

const PHASE1_TABLE = read!(joinpath(LOOKUP_PATH, "phase1.dat"), Phase1Table(undef))
const PHASE2_TABLE = read!(joinpath(LOOKUP_PATH, "phase2.dat"), Phase2Table(undef))

