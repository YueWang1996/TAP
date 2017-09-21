procedure refinement_proof_step_init();
  modifies cpu_evbase,
           cpu_evmask,
           cpu_eptbr,
           cpu_ptbr,
           cpu_drbmap,
           cpu_edrbmap,
           cpu_parbase,
           cpu_eparbase,
           cpu_parmask,
           cpu_eparmask,
           cpu_dmarbase,
           cpu_dmarmask,
           owner,
           mem,
           os_bitmap,
           core_info_enclave_id,
           core_info_thread_id,
           enclave_metadata_valid,
           enclave_metadata_is_initialized,
           thread_metadata_valid,
           os_bitmap;
  modifies cpu_enclave_id,
           cpu_addr_map,
           cpu_addr_valid,
           untrusted_addr_map,
           untrusted_addr_valid,
           untrusted_pc,
           untrusted_regs,
           cpu_pc,
           cpu_regs,
           cpu_owner_map,
           cpu_mem,
           cache_valid_map,
           tap_enclave_metadata_valid;
    ensures cpu_ptbr == k2_ppn_t;
    ensures cpu_parbase == 0bv9 ++ 0bv3 ++ 0bv12;
    ensures cpu_parmask == 0bv9 ++ 0bv3 ++ 255bv12;
    ensures cpu_eparbase == cpu_parbase;
    ensures cpu_eparmask == cpu_parmask;
    ensures cpu_dmarbase == 0bv9 ++ 0bv3 ++ 256bv12;
    ensures cpu_dmarmask == 0bv9 ++ 0bv3 ++ 255bv12;
    ensures (forall eid: enclave_id_t :: enclave_metadata_is_initialized[eid] ==> enclave_metadata_valid[eid]);
    ensures (forall eid: enclave_id_t :: enclave_metadata_valid[eid] ==> assigned(eid));
    ensures (forall eid: enclave_id_t :: enclave_metadata_valid[eid] ==> (owner[dram_region_for(eid)] == metadata_enclave_id));
    ensures (forall r: region_t, e: enclave_id_t :: ((owner[r] == e) && assigned(e)) ==> enclave_metadata_valid[e]);
    ensures (forall r: region_t, e: enclave_id_t :: ((owner[r] == e) && assigned(e)) ==> (owner[dram_region_for(e)] == metadata_enclave_id));
    ensures (forall p: wap_addr_t :: (owner[dram_region_for_w(p)] == free_enclave_id) ==> (mem[p] == k0_word_t));
    ensures (forall eid: enclave_id_t :: enclave_metadata_valid[eid] ==> (owner[dram_region_for(eid)] == metadata_enclave_id));
    ensures (forall r: region_t, eid: enclave_id_t :: (enclave_metadata_valid[eid] && assigned(eid)) ==> (owner[r] == eid <==> AND_8(enclave_metadata_bitmap[eid], LSHIFT_8(1bv8, 0bv5 ++ r)) != 0bv8));
    ensures (forall eid1, eid2: enclave_id_t :: (eid1 != eid2 && assigned(eid1) && assigned(eid2) && enclave_metadata_valid[eid1] && enclave_metadata_valid[eid2]) ==> (disjoint_bitmaps(enclave_metadata_bitmap[eid1], enclave_metadata_bitmap[eid2])));
    ensures (forall eid: enclave_id_t :: (assigned(eid) && enclave_metadata_valid[eid]) ==> disjoint_bitmaps(enclave_metadata_bitmap[eid], os_bitmap));
    ensures (forall r: region_t, e: enclave_id_t :: (enclave_metadata_valid[e] && assigned(e)) ==> (owner[r] != e ==> (read_bitmap(enclave_metadata_bitmap[e], r) == 0bv1)));
    ensures (forall r: region_t, e: enclave_id_t :: enclave_metadata_valid[e] ==> (!assigned(owner[r]) ==> (read_bitmap(enclave_metadata_bitmap[e], r) == 0bv1)));
    ensures (forall r: region_t :: ((owner[r] == null_enclave_id) ==> read_bitmap(os_bitmap, r) == 1bv1));
    ensures (forall r: region_t :: ((owner[r] != null_enclave_id) ==> read_bitmap(os_bitmap, r) == 0bv1));
    ensures (forall r: region_t, e : enclave_id_t :: ((owner[r] == e && assigned(e)) ==> (read_bitmap(enclave_metadata_bitmap[e], r) == 1bv1)));
    ensures (forall r: region_t, e : enclave_id_t :: ((owner[r] != e && assigned(e) && enclave_metadata_valid[e]) ==> (read_bitmap(enclave_metadata_bitmap[e], r) == 0bv1)));
    ensures os_bitmap == cpu_drbmap;
    ensures assigned(core_info_enclave_id) || (core_info_enclave_id == null_enclave_id);
    ensures assigned(core_info_enclave_id) ==> (enclave_metadata_valid[core_info_enclave_id] && enclave_metadata_is_initialized[core_info_enclave_id]);
    ensures assigned(core_info_enclave_id) ==> enclave_metadata_bitmap[core_info_enclave_id] == cpu_edrbmap;
    ensures (forall e1: enclave_id_t, e2: enclave_id_t :: (enclave_metadata_is_initialized[e1] && enclave_metadata_is_initialized[e2] && e1 != e2) ==> (enclave_metadata_load_eptbr[e1] != enclave_metadata_load_eptbr[e2]));
    ensures (forall e: enclave_id_t, r: region_t :: (enclave_metadata_valid[e] && enclave_metadata_is_initialized[e]) ==> (dram_region_for(enclave_metadata_load_eptbr[e] ++ 0bv12) == r ==> owner[r] == e));
    ensures (core_info_enclave_id != blocked_enclave_id);
    ensures core_info_enclave_id != null_enclave_id ==> (enclave_metadata_load_eptbr[core_info_enclave_id] == cpu_eptbr);
    ensures core_info_enclave_id != null_enclave_id ==> (enclave_metadata_ev_base[core_info_enclave_id] == cpu_evbase);
    ensures core_info_enclave_id != null_enclave_id ==> (enclave_metadata_ev_mask[core_info_enclave_id] == cpu_evmask);
    ensures (cpu_enclave_id != tap_blocked_enc_id);
    ensures (!tap_enclave_metadata_valid[tap_blocked_enc_id]);
    ensures (cpu_enclave_id == tap_null_enc_id) ==> ((cpu_addr_map == untrusted_addr_map) && (forall v : vaddr_t :: tap_perm_eq(cpu_addr_valid[v], untrusted_addr_valid[v])));
    ensures (cpu_enclave_id != tap_null_enc_id) ==> (cpu_addr_map == tap_enclave_metadata_addr_map[cpu_enclave_id]);
    ensures (cpu_enclave_id != tap_null_enc_id) ==> (forall v : vaddr_t :: tap_perm_eq(cpu_addr_valid[v], tap_enclave_metadata_addr_valid[cpu_enclave_id][v]));
    ensures (forall pa : wap_addr_t, e : tap_enclave_id_t :: (e != tap_null_enc_id && e != tap_blocked_enc_id && e != tap_metadata_enc_id && !tap_enclave_metadata_valid[e]) ==> (cpu_owner_map[pa] != e));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id == null_enclave_id && cpu_enclave_id == tap_null_enc_id && vpn == vaddr2vpn(va)) ==> tap_sanctum_perm_eq(cpu_addr_valid[va], ptbl_acl_map[cpu_ptbr, vpn]));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id == null_enclave_id && cpu_enclave_id == tap_null_enc_id && vpn == vaddr2vpn(va)) ==> (cpu_addr_map[va] == paddr2wpaddr(ptbl_addr_map[cpu_ptbr, vpn] ++ vaddr2offset(va))));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id != null_enclave_id && cpu_enclave_id != tap_null_enc_id) ==> (in_enclave_mem(va, cpu_evbase, cpu_evmask) <==> tap_enclave_metadata_addr_excl[cpu_enclave_id][va]));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id != null_enclave_id && cpu_enclave_id != tap_null_enc_id && vpn == vaddr2vpn(va) && in_enclave_mem(va, cpu_evbase, cpu_evmask) && tap_enclave_metadata_addr_excl[cpu_enclave_id][va]) ==> tap_sanctum_perm_eq(cpu_addr_valid[va], ptbl_acl_map[cpu_eptbr, vpn]));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id != null_enclave_id && cpu_enclave_id != tap_null_enc_id && vpn == vaddr2vpn(va) && in_enclave_mem(va, cpu_evbase, cpu_evmask) && tap_enclave_metadata_addr_excl[cpu_enclave_id][va]) ==> (cpu_addr_map[va] == paddr2wpaddr(ptbl_addr_map[cpu_eptbr, vpn] ++ vaddr2offset(va))));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id != null_enclave_id && cpu_enclave_id != tap_null_enc_id && vpn == vaddr2vpn(va) && !in_enclave_mem(va, cpu_evbase, cpu_evmask) && !tap_enclave_metadata_addr_excl[cpu_enclave_id][va]) ==> tap_sanctum_perm_eq(cpu_addr_valid[va], ptbl_acl_map[cpu_ptbr, vpn]));
    ensures (forall va: vaddr_t, vpn : vpn_t :: (core_info_enclave_id != null_enclave_id && cpu_enclave_id != tap_null_enc_id && vpn == vaddr2vpn(va) && !in_enclave_mem(va, cpu_evbase, cpu_evmask) && !tap_enclave_metadata_addr_excl[cpu_enclave_id][va]) ==> (cpu_addr_map[va] == paddr2wpaddr(ptbl_addr_map[cpu_ptbr, vpn] ++ vaddr2offset(va))));
    ensures cpu_enclave_id == enclave_id_bv2int(core_info_enclave_id);
    ensures (cpu_enclave_id == tap_null_enc_id) <==> (core_info_enclave_id == null_enclave_id);
    ensures ((cpu_enclave_id != tap_null_enc_id) ==> tap_enclave_metadata_valid[cpu_enclave_id]) && (core_info_enclave_id != null_enclave_id ==> enclave_metadata_valid[core_info_enclave_id]);
    ensures (forall pa: wap_addr_t :: cpu_mem[pa] == mem[pa]);
    ensures (forall eid: enclave_id_t :: enclave_metadata_is_initialized[eid] <==> tap_enclave_metadata_valid[enclave_id_bv2int(eid)]);
    ensures (forall va: vaddr_t :: (untrusted_addr_map[va] == paddr2wpaddr(ptbl_addr_map[cpu_ptbr, vaddr2vpn(va)] ++ vaddr2offset(va))));
    ensures (forall va: vaddr_t, eid: enclave_id_t :: tap_enclave_metadata_valid[enclave_id_bv2int(eid)] ==> (if in_enclave_mem(va, enclave_metadata_ev_base[eid], enclave_metadata_ev_mask[eid]) then (tap_enclave_metadata_addr_map[enclave_id_bv2int(eid)][va] == paddr2wpaddr(ptbl_addr_map[enclave_metadata_load_eptbr[eid], vaddr2vpn(va)] ++ vaddr2offset(va))) else (tap_enclave_metadata_addr_map[enclave_id_bv2int(eid)][va] == paddr2wpaddr(ptbl_addr_map[cpu_ptbr, vaddr2vpn(va)] ++ vaddr2offset(va)))));
    ensures (forall va : vaddr_t :: tap_sanctum_perm_eq(untrusted_addr_valid[va], ptbl_acl_map[cpu_ptbr, vaddr2vpn(va)]));
    ensures (forall eid: enclave_id_t, va:vaddr_t :: enclave_metadata_is_initialized[eid] ==> (in_enclave_mem(va, enclave_metadata_ev_base[eid], enclave_metadata_ev_mask[eid]) <==> tap_enclave_metadata_addr_excl[enclave_id_bv2int(eid)][va]));
    ensures (forall eid: enclave_id_t, va:vaddr_t :: tap_enclave_metadata_valid[enclave_id_bv2int(eid)] ==> (in_enclave_mem(va, enclave_metadata_ev_base[eid], enclave_metadata_ev_mask[eid]) <==> tap_enclave_metadata_addr_excl[enclave_id_bv2int(eid)][va]));
    ensures (forall va: vaddr_t, eid: enclave_id_t, t_eid : tap_enclave_id_t, vpn : vpn_t, eptbr : ppn_t :: (t_eid == enclave_id_bv2int(eid) && vpn == vaddr2vpn(va) && eptbr == enclave_metadata_load_eptbr[eid] && tap_enclave_metadata_valid[t_eid] && in_enclave_mem(va, enclave_metadata_ev_base[eid], enclave_metadata_ev_mask[eid])) ==> tap_sanctum_perm_eq(tap_enclave_metadata_addr_valid[t_eid][va], ptbl_acl_map[eptbr, vpn]));
    ensures (forall va: vaddr_t, eid: enclave_id_t, t_eid : tap_enclave_id_t, vpn : vpn_t, eptbr : ppn_t :: (t_eid == enclave_id_bv2int(eid) && vpn == vaddr2vpn(va) && eptbr == enclave_metadata_load_eptbr[eid] && tap_enclave_metadata_valid[t_eid] && tap_enclave_metadata_addr_excl[t_eid][va]) ==> tap_sanctum_perm_eq(tap_enclave_metadata_addr_valid[t_eid][va], ptbl_acl_map[eptbr, vpn]));
    ensures (forall va: vaddr_t, eid: enclave_id_t, t_eid : tap_enclave_id_t, vpn : vpn_t :: (t_eid == enclave_id_bv2int(eid) && vpn == vaddr2vpn(va) && tap_enclave_metadata_valid[t_eid] && !in_enclave_mem(va, enclave_metadata_ev_base[eid], enclave_metadata_ev_mask[eid])) ==> tap_sanctum_perm_eq(tap_enclave_metadata_addr_valid[t_eid][va], ptbl_acl_map[cpu_ptbr, vpn]));
    ensures (forall va: vaddr_t, eid: enclave_id_t, t_eid : tap_enclave_id_t, vpn : vpn_t :: (t_eid == enclave_id_bv2int(eid) && vpn == vaddr2vpn(va) && tap_enclave_metadata_valid[t_eid] && !tap_enclave_metadata_addr_excl[t_eid][va]) ==> tap_sanctum_perm_eq(tap_enclave_metadata_addr_valid[t_eid][va], ptbl_acl_map[cpu_ptbr, vpn]));
    ensures (forall pa: wap_addr_t, eid : enclave_id_t :: enclave_metadata_is_initialized[eid] ==> (owner[dram_region_for_w(pa)] == eid <==> (cpu_owner_map[pa] == enclave_id_bv2int(eid))));
    ensures (forall pa: wap_addr_t, eid : enclave_id_t :: (assigned(eid) && !enclave_metadata_is_initialized[eid]) ==> (owner[dram_region_for_w(pa)] == eid ==> (cpu_owner_map[pa] == tap_null_enc_id)));
    ensures (forall pa: wap_addr_t :: (owner[dram_region_for_w(pa)] == null_enclave_id) ==> (tap_null_enc_id == cpu_owner_map[pa]));
    ensures (forall pa: wap_addr_t :: (owner[dram_region_for_w(pa)] == free_enclave_id) ==> (tap_null_enc_id == cpu_owner_map[pa]));
    ensures (forall pa: wap_addr_t :: (owner[dram_region_for_w(pa)] == metadata_enclave_id) <==> (tap_metadata_enc_id == cpu_owner_map[pa]));
    ensures (forall pa: wap_addr_t :: (owner[dram_region_for_w(pa)] == blocked_enclave_id) <==> (tap_blocked_enc_id == cpu_owner_map[pa]));
    ensures (forall pa: wap_addr_t :: (read_bitmap(os_bitmap, dram_region_for_w(pa)) == 1bv1) ==> (cpu_owner_map[pa] == tap_null_enc_id));
