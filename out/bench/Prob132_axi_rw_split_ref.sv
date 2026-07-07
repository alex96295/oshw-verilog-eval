
`ifndef AXI_ASSIGN_SVH_
`define AXI_ASSIGN_SVH_
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  `__AXI_TO_AW(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep)  \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                         \
  `__AXI_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)     \
  __opt_as __lhs.w_valid = __rhs.w_valid;                           \
  __opt_as __lhs.b_ready = __rhs.b_ready;                           \
  `__AXI_TO_AR(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep)  \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                         \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                         \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                         \
  __opt_as __lhs.w_ready = __rhs.w_ready;                           \
  __opt_as __lhs.b_valid = __rhs.b_valid;                           \
  `__AXI_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)     \
  __opt_as __lhs.r_valid = __rhs.r_valid;                           \
  `__AXI_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_ASSIGN_AW(dst, src)               \
  `__AXI_TO_AW(assign, dst.aw, _, src.aw, _)  \
  assign dst.aw_valid = src.aw_valid;         \
  assign src.aw_ready = dst.aw_ready;
`define AXI_ASSIGN_W(dst, src)                \
  `__AXI_TO_W(assign, dst.w, _, src.w, _)     \
  assign dst.w_valid  = src.w_valid;          \
  assign src.w_ready  = dst.w_ready;
`define AXI_ASSIGN_B(dst, src)                \
  `__AXI_TO_B(assign, dst.b, _, src.b, _)     \
  assign dst.b_valid  = src.b_valid;          \
  assign src.b_ready  = dst.b_ready;
`define AXI_ASSIGN_AR(dst, src)               \
  `__AXI_TO_AR(assign, dst.ar, _, src.ar, _)  \
  assign dst.ar_valid = src.ar_valid;         \
  assign src.ar_ready = dst.ar_ready;
`define AXI_ASSIGN_R(dst, src)                \
  `__AXI_TO_R(assign, dst.r, _, src.r, _)     \
  assign dst.r_valid  = src.r_valid;          \
  assign src.r_ready  = dst.r_ready;
`define AXI_ASSIGN(slv, mst)  \
  `AXI_ASSIGN_AW(slv, mst)    \
  `AXI_ASSIGN_W(slv, mst)     \
  `AXI_ASSIGN_B(mst, slv)     \
  `AXI_ASSIGN_AR(slv, mst)    \
  `AXI_ASSIGN_R(mst, slv)
`define AXI_ASSIGN_MONITOR(mon_dv, axi_if)          \
  `__AXI_TO_AW(assign, mon_dv.aw, _, axi_if.aw, _)  \
  assign mon_dv.aw_valid  = axi_if.aw_valid;        \
  assign mon_dv.aw_ready  = axi_if.aw_ready;        \
  `__AXI_TO_W(assign, mon_dv.w, _, axi_if.w, _)     \
  assign mon_dv.w_valid   = axi_if.w_valid;         \
  assign mon_dv.w_ready   = axi_if.w_ready;         \
  `__AXI_TO_B(assign, mon_dv.b, _, axi_if.b, _)     \
  assign mon_dv.b_valid   = axi_if.b_valid;         \
  assign mon_dv.b_ready   = axi_if.b_ready;         \
  `__AXI_TO_AR(assign, mon_dv.ar, _, axi_if.ar, _)  \
  assign mon_dv.ar_valid  = axi_if.ar_valid;        \
  assign mon_dv.ar_ready  = axi_if.ar_ready;        \
  `__AXI_TO_R(assign, mon_dv.r, _, axi_if.r, _)     \
  assign mon_dv.r_valid   = axi_if.r_valid;         \
  assign mon_dv.r_ready   = axi_if.r_ready;
`define AXI_SET_FROM_AW(axi_if, aw_struct)      `__AXI_TO_AW(, axi_if.aw, _, aw_struct, .)
`define AXI_SET_FROM_W(axi_if, w_struct)        `__AXI_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_SET_FROM_B(axi_if, b_struct)        `__AXI_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_SET_FROM_AR(axi_if, ar_struct)      `__AXI_TO_AR(, axi_if.ar, _, ar_struct, .)
`define AXI_SET_FROM_R(axi_if, r_struct)        `__AXI_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_SET_FROM_REQ(axi_if, req_struct)    `__AXI_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_TO_AW(assign, axi_if.aw, _, aw_struct, .)
`define AXI_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_TO_AR(assign, axi_if.ar, _, ar_struct, .)
`define AXI_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_SET_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(, aw_struct, ., axi_if.aw, _)
`define AXI_SET_TO_W(w_struct, axi_if)       `__AXI_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_SET_TO_B(b_struct, axi_if)       `__AXI_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_SET_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(, ar_struct, ., axi_if.ar, _)
`define AXI_SET_TO_R(r_struct, axi_if)       `__AXI_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_SET_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_SET_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(assign, aw_struct, ., axi_if.aw, _)
`define AXI_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(assign, ar_struct, ., axi_if.ar, _)
`define AXI_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_SET_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(, lhs, ., rhs, .)
`define AXI_SET_W_STRUCT(lhs, rhs)       `__AXI_TO_W(, lhs, ., rhs, .)
`define AXI_SET_B_STRUCT(lhs, rhs)       `__AXI_TO_B(, lhs, ., rhs, .)
`define AXI_SET_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(, lhs, ., rhs, .)
`define AXI_SET_R_STRUCT(lhs, rhs)       `__AXI_TO_R(, lhs, ., rhs, .)
`define AXI_SET_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(, lhs, ., rhs, .)
`define AXI_SET_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(, lhs, ., rhs, .)
`define AXI_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_TO_W(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_TO_B(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_TO_R(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(assign, lhs, ., rhs, .)
`define __AXI_LITE_TO_AX(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs``__lhs_sep``addr = __rhs``__rhs_sep``addr;             \
  __opt_as __lhs``__lhs_sep``prot = __rhs``__rhs_sep``prot;
`define __AXI_LITE_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``strb = __rhs``__rhs_sep``strb;
`define __AXI_LITE_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep) \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                             \
  `__AXI_LITE_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)    \
  __opt_as __lhs.w_valid = __rhs.w_valid;                               \
  __opt_as __lhs.b_ready = __rhs.b_ready;                               \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep) \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                             \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_LITE_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                               \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                               \
  __opt_as __lhs.w_ready = __rhs.w_ready;                                 \
  __opt_as __lhs.b_valid = __rhs.b_valid;                                 \
  `__AXI_LITE_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)      \
  __opt_as __lhs.r_valid = __rhs.r_valid;                                 \
  `__AXI_LITE_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_LITE_ASSIGN_AW(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.aw, _, src.aw, _) \
  assign dst.aw_valid = src.aw_valid;             \
  assign src.aw_ready = dst.aw_ready;
`define AXI_LITE_ASSIGN_W(dst, src)             \
  `__AXI_LITE_TO_W(assign, dst.w, _, src.w, _)  \
  assign dst.w_valid  = src.w_valid;            \
  assign src.w_ready  = dst.w_ready;
`define AXI_LITE_ASSIGN_B(dst, src)             \
  `__AXI_LITE_TO_B(assign, dst.b, _, src.b, _)  \
  assign dst.b_valid  = src.b_valid;            \
  assign src.b_ready  = dst.b_ready;
`define AXI_LITE_ASSIGN_AR(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.ar, _, src.ar, _) \
  assign dst.ar_valid = src.ar_valid;             \
  assign src.ar_ready = dst.ar_ready;
`define AXI_LITE_ASSIGN_R(dst, src)             \
  `__AXI_LITE_TO_R(assign, dst.r, _, src.r, _)  \
  assign dst.r_valid  = src.r_valid;            \
  assign src.r_ready  = dst.r_ready;
`define AXI_LITE_ASSIGN(slv, mst) \
  `AXI_LITE_ASSIGN_AW(slv, mst)   \
  `AXI_LITE_ASSIGN_W(slv, mst)    \
  `AXI_LITE_ASSIGN_B(mst, slv)    \
  `AXI_LITE_ASSIGN_AR(slv, mst)   \
  `AXI_LITE_ASSIGN_R(mst, slv)
`define AXI_LITE_SET_FROM_AW(axi_if, aw_struct)      `__AXI_LITE_TO_AX(, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_SET_FROM_W(axi_if, w_struct)        `__AXI_LITE_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_LITE_SET_FROM_B(axi_if, b_struct)        `__AXI_LITE_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_LITE_SET_FROM_AR(axi_if, ar_struct)      `__AXI_LITE_TO_AX(, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_SET_FROM_R(axi_if, r_struct)        `__AXI_LITE_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_LITE_SET_FROM_REQ(axi_if, req_struct)    `__AXI_LITE_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_LITE_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_LITE_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_LITE_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_LITE_TO_AX(assign, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_LITE_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_LITE_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_LITE_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_LITE_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_LITE_TO_AX(assign, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_LITE_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_LITE_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_LITE_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_LITE_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_LITE_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_LITE_SET_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_SET_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_LITE_SET_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_LITE_SET_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_SET_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_LITE_SET_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_LITE_SET_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(assign, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_LITE_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_LITE_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(assign, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_LITE_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_LITE_SET_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(, lhs, ., rhs, .)
`define AXI_LITE_SET_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(, lhs, ., rhs, .)
`define AXI_LITE_SET_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(, lhs, ., rhs, .)
`define AXI_LITE_SET_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(, lhs, ., rhs, .)
`define AXI_LITE_SET_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_MASTER_TO_FLAT(pat, req, rsp) \
  assign m_axi_``pat``_awvalid  = req.aw_valid;  \
  assign m_axi_``pat``_awid     = req.aw.id;     \
  assign m_axi_``pat``_awaddr   = req.aw.addr;   \
  assign m_axi_``pat``_awlen    = req.aw.len;    \
  assign m_axi_``pat``_awsize   = req.aw.size;   \
  assign m_axi_``pat``_awburst  = req.aw.burst;  \
  assign m_axi_``pat``_awlock   = req.aw.lock;   \
  assign m_axi_``pat``_awcache  = req.aw.cache;  \
  assign m_axi_``pat``_awprot   = req.aw.prot;   \
  assign m_axi_``pat``_awqos    = req.aw.qos;    \
  assign m_axi_``pat``_awregion = req.aw.region; \
  assign m_axi_``pat``_awuser   = req.aw.user;   \
                                                 \
  assign m_axi_``pat``_wvalid   = req.w_valid;   \
  assign m_axi_``pat``_wdata    = req.w.data;    \
  assign m_axi_``pat``_wstrb    = req.w.strb;    \
  assign m_axi_``pat``_wlast    = req.w.last;    \
  assign m_axi_``pat``_wuser    = req.w.user;    \
                                                 \
  assign m_axi_``pat``_bready   = req.b_ready;   \
                                                 \
  assign m_axi_``pat``_arvalid  = req.ar_valid;  \
  assign m_axi_``pat``_arid     = req.ar.id;     \
  assign m_axi_``pat``_araddr   = req.ar.addr;   \
  assign m_axi_``pat``_arlen    = req.ar.len;    \
  assign m_axi_``pat``_arsize   = req.ar.size;   \
  assign m_axi_``pat``_arburst  = req.ar.burst;  \
  assign m_axi_``pat``_arlock   = req.ar.lock;   \
  assign m_axi_``pat``_arcache  = req.ar.cache;  \
  assign m_axi_``pat``_arprot   = req.ar.prot;   \
  assign m_axi_``pat``_arqos    = req.ar.qos;    \
  assign m_axi_``pat``_arregion = req.ar.region; \
  assign m_axi_``pat``_aruser   = req.ar.user;   \
                                                 \
  assign m_axi_``pat``_rready   = req.r_ready;   \
                                                 \
  assign rsp.aw_ready = m_axi_``pat``_awready;   \
  assign rsp.ar_ready = m_axi_``pat``_arready;   \
  assign rsp.w_ready  = m_axi_``pat``_wready;    \
                                                 \
  assign rsp.b_valid  = m_axi_``pat``_bvalid;    \
  assign rsp.b.id     = m_axi_``pat``_bid;       \
  assign rsp.b.resp   = m_axi_``pat``_bresp;     \
  assign rsp.b.user   = m_axi_``pat``_buser;     \
                                                 \
  assign rsp.r_valid  = m_axi_``pat``_rvalid;    \
  assign rsp.r.id     = m_axi_``pat``_rid;       \
  assign rsp.r.data   = m_axi_``pat``_rdata;     \
  assign rsp.r.resp   = m_axi_``pat``_rresp;     \
  assign rsp.r.last   = m_axi_``pat``_rlast;     \
  assign rsp.r.user   = m_axi_``pat``_ruser;
`define AXI_ASSIGN_SLAVE_TO_FLAT(pat, req, rsp)  \
  assign req.aw_valid  = s_axi_``pat``_awvalid;  \
  assign req.aw.id     = s_axi_``pat``_awid;     \
  assign req.aw.addr   = s_axi_``pat``_awaddr;   \
  assign req.aw.len    = s_axi_``pat``_awlen;    \
  assign req.aw.size   = s_axi_``pat``_awsize;   \
  assign req.aw.burst  = s_axi_``pat``_awburst;  \
  assign req.aw.lock   = s_axi_``pat``_awlock;   \
  assign req.aw.cache  = s_axi_``pat``_awcache;  \
  assign req.aw.prot   = s_axi_``pat``_awprot;   \
  assign req.aw.qos    = s_axi_``pat``_awqos;    \
  assign req.aw.region = s_axi_``pat``_awregion; \
  assign req.aw.user   = s_axi_``pat``_awuser;   \
                                                 \
  assign req.w_valid   = s_axi_``pat``_wvalid;   \
  assign req.w.data    = s_axi_``pat``_wdata;    \
  assign req.w.strb    = s_axi_``pat``_wstrb;    \
  assign req.w.last    = s_axi_``pat``_wlast;    \
  assign req.w.user    = s_axi_``pat``_wuser;    \
                                                 \
  assign req.b_ready   = s_axi_``pat``_bready;   \
                                                 \
  assign req.ar_valid  = s_axi_``pat``_arvalid;  \
  assign req.ar.id     = s_axi_``pat``_arid;     \
  assign req.ar.addr   = s_axi_``pat``_araddr;   \
  assign req.ar.len    = s_axi_``pat``_arlen;    \
  assign req.ar.size   = s_axi_``pat``_arsize;   \
  assign req.ar.burst  = s_axi_``pat``_arburst;  \
  assign req.ar.lock   = s_axi_``pat``_arlock;   \
  assign req.ar.cache  = s_axi_``pat``_arcache;  \
  assign req.ar.prot   = s_axi_``pat``_arprot;   \
  assign req.ar.qos    = s_axi_``pat``_arqos;    \
  assign req.ar.region = s_axi_``pat``_arregion; \
  assign req.ar.user   = s_axi_``pat``_aruser;   \
                                                 \
  assign req.r_ready   = s_axi_``pat``_rready;   \
                                                 \
  assign s_axi_``pat``_awready = rsp.aw_ready;   \
  assign s_axi_``pat``_arready = rsp.ar_ready;   \
  assign s_axi_``pat``_wready  = rsp.w_ready;    \
                                                 \
  assign s_axi_``pat``_bvalid  = rsp.b_valid;    \
  assign s_axi_``pat``_bid     = rsp.b.id;       \
  assign s_axi_``pat``_bresp   = rsp.b.resp;     \
  assign s_axi_``pat``_buser   = rsp.b.user;     \
                                                 \
  assign s_axi_``pat``_rvalid  = rsp.r_valid;    \
  assign s_axi_``pat``_rid     = rsp.r.id;       \
  assign s_axi_``pat``_rdata   = rsp.r.data;     \
  assign s_axi_``pat``_rresp   = rsp.r.resp;     \
  assign s_axi_``pat``_rlast   = rsp.r.last;     \
  assign s_axi_``pat``_ruser   = rsp.r.user;
`define AXI_ASSIGN_TO_FLAT_PORT(pat, req, rsp)  \
  .``pat``_awvalid  ( req.aw_valid  ), \
  .``pat``_awid     ( req.aw.id     ), \
  .``pat``_awaddr   ( req.aw.addr   ), \
  .``pat``_awlen    ( req.aw.len    ), \
  .``pat``_awsize   ( req.aw.size   ), \
  .``pat``_awburst  ( req.aw.burst  ), \
  .``pat``_awlock   ( req.aw.lock   ), \
  .``pat``_awcache  ( req.aw.cache  ), \
  .``pat``_awprot   ( req.aw.prot   ), \
  .``pat``_awqos    ( req.aw.qos    ), \
  .``pat``_awregion ( req.aw.region ), \
  .``pat``_awuser   ( req.aw.user   ), \
                                       \
  .``pat``_wvalid   ( req.w_valid   ), \
  .``pat``_wdata    ( req.w.data    ), \
  .``pat``_wstrb    ( req.w.strb    ), \
  .``pat``_wlast    ( req.w.last    ), \
  .``pat``_wuser    ( req.w.user    ), \
                                       \
  .``pat``_bready   ( req.b_ready   ), \
                                       \
  .``pat``_arvalid  ( req.ar_valid  ), \
  .``pat``_arid     ( req.ar.id     ), \
  .``pat``_araddr   ( req.ar.addr   ), \
  .``pat``_arlen    ( req.ar.len    ), \
  .``pat``_arsize   ( req.ar.size   ), \
  .``pat``_arburst  ( req.ar.burst  ), \
  .``pat``_arlock   ( req.ar.lock   ), \
  .``pat``_arcache  ( req.ar.cache  ), \
  .``pat``_arprot   ( req.ar.prot   ), \
  .``pat``_arqos    ( req.ar.qos    ), \
  .``pat``_arregion ( req.ar.region ), \
  .``pat``_aruser   ( req.ar.user   ), \
                                       \
  .``pat``_rready   ( req.r_ready   ), \
                                       \
  .``pat``_awready  ( rsp.aw_ready  ), \
  .``pat``_arready  ( rsp.ar_ready  ), \
  .``pat``_wready   ( rsp.w_ready   ), \
                                       \
  .``pat``_bvalid   ( rsp.b_valid   ), \
  .``pat``_bid      ( rsp.b.id      ), \
  .``pat``_bresp    ( rsp.b.resp    ), \
  .``pat``_buser    ( rsp.b.user    ), \
                                       \
  .``pat``_rvalid   ( rsp.r_valid   ), \
  .``pat``_rid      ( rsp.r.id      ), \
  .``pat``_rdata    ( rsp.r.data    ), \
  .``pat``_rresp    ( rsp.r.resp    ), \
  .``pat``_rlast    ( rsp.r.last    ), \
  .``pat``_ruser    ( rsp.r.user    )
`define AXI_ASSIGN_MASTER_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(m_axi_``name``, req, rsp)
`define AXI_ASSIGN_SLAVE_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(s_axi_``name``, req, rsp)
`define AXI_HIGHLIGHT(__name, __aw_t, __w_t, __b_t, __ar_t, __r_t, __req, __resp) \
  signal_highlighter #(                                                           \
    .T ( __aw_t )                                                                 \
  ) i_signal_highlighter_``__name``_aw (                                          \
    .ready_i ( __resp.aw_ready ),                                                 \
    .valid_i ( __req.aw_valid  ),                                                 \
    .data_i  ( __req.aw        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __w_t )                                                                  \
  ) i_signal_highlighter_``__name``_w (                                           \
    .ready_i ( __resp.w_ready ),                                                  \
    .valid_i ( __req.w_valid  ),                                                  \
    .data_i  ( __req.w        )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __b_t )                                                                  \
  ) i_signal_highlighter_``__name``_b (                                           \
    .ready_i ( __req.b_ready  ),                                                  \
    .valid_i ( __resp.b_valid ),                                                  \
    .data_i  ( __resp.b       )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __ar_t )                                                                 \
  ) i_signal_highlighter_``__name``_ar (                                          \
    .ready_i ( __resp.ar_ready ),                                                 \
    .valid_i ( __req.ar_valid  ),                                                 \
    .data_i  ( __req.ar        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __r_t )                                                                  \
  ) i_signal_highlighter_``__name``_r (                                           \
    .ready_i ( __req.r_ready  ),                                                  \
    .valid_i ( __resp.r_valid ),                                                  \
    .data_i  ( __resp.r       )                                                   \
  );
`endif
`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH
`ifdef UVM
  
  package assert_rpt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    function void assert_rpt(string msg);
      `uvm_error("ASSERT FAILED", msg)
    endfunction
  endpackage`endif
`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif   
`endif
`ifdef ASSERTS_OVERRIDE_ON`ifndef INC_ASSERT
`define INC_ASSERT`endif`endif
`define ASSERT_STRINGIFY(__x) `"__x`"
`ifndef ASSERT_RPT
`define ASSERT_RPT(__name, __desc = "")                                                 \
`ifdef UVM                                                                              \
  assert_rpt_pkg::assert_rpt($sformatf("[%m] %s: %s (%s:%0d)",                          \
                             __name, __desc, `__FILE__, `__LINE__));                    \
`else                                                                                   \
  $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__); \
`endif
`endif
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define ASSERT_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assert (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSERT_INIT(__name, __prop, __desc = "")       \
`ifdef INC_ASSERT                                      \
  initial begin                                        \
    __name: assert (__prop)                            \
      else begin                                       \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
      end                                              \
  end                                                  \
`endif
`define ASSERT_FINAL(__name, __prop, __desc = "")                            \
`ifdef INC_ASSERT                                                            \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                       \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                           \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))                      \
    else begin                                                                                              \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                        \
    end                                                                                                     \
`endif
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst, __desc)                                                \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef INC_ASSERT                                                                       \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));      \
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst, __desc)                                         \
`endif
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                  \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst, __desc)                                                   \
`endif
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                       \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst, __desc)                                                    \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst, __desc)                                                \
`endif
`define ASSERT_STABLE(__name, __valid, __ready, __data, __mask = '0, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                                           \
  `ASSERT(__name, (__valid) && !(__ready) |=> $stable((__data) & ~(__mask)), __clk, __rst, __desc)                                          \
`endif
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSUME_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assume (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef FPV_ON                                                                                             \
   `ASSUME(__name, __prop, __clk, __rst, __desc)                                                          \
`endif
`define ASSUME_I_FPV(__name, __prop, __desc = "") \
`ifdef FPV_ON                                     \
   `ASSUME_I(__name, __prop, __desc)              \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`endif 
module TopModule #(
  parameter type axi_req_t  = logic,
  parameter type axi_resp_t = logic
) (
  input  logic      clk_i,
  input  logic      rst_ni,
  
  input  axi_req_t  slv_req_i,
  output axi_resp_t slv_resp_o,
  
  output axi_req_t  mst_read_req_o,
  input  axi_resp_t mst_read_resp_i,
  
  output axi_req_t  mst_write_req_o,
  input  axi_resp_t mst_write_resp_i
);
  
  
  
  
  `AXI_ASSIGN_AR_STRUCT ( mst_read_req_o.ar  , slv_req_i.ar       )
  `AXI_ASSIGN_R_STRUCT  ( slv_resp_o.r       , mst_read_resp_i.r  )
  
  assign mst_read_req_o.aw        = '0;
  assign mst_read_req_o.w         = '0;
  
  
  
  
  assign mst_read_req_o.ar_valid  = slv_req_i.ar_valid;
  assign slv_resp_o.ar_ready      = mst_read_resp_i.ar_ready;
  
  assign slv_resp_o.r_valid       = mst_read_resp_i.r_valid;
  assign mst_read_req_o.r_ready   = slv_req_i.r_ready;
  
  assign mst_read_req_o.aw_valid  = 1'b0;
  assign mst_read_req_o.w_valid   = 1'b0;
  assign mst_read_req_o.b_ready   = 1'b0;
  
  `ASSERT_NEVER(mst_read_resp_b_valid, mst_read_resp_i.b_valid, clk_i, !rst_ni)
  
  
  
  
  `AXI_ASSIGN_AW_STRUCT ( mst_write_req_o.aw , slv_req_i.aw       )
  `AXI_ASSIGN_W_STRUCT  ( mst_write_req_o.w  , slv_req_i.w        )
  `AXI_ASSIGN_B_STRUCT  ( slv_resp_o.b       , mst_write_resp_i.b )
  
  assign mst_write_req_o.ar       = '0;
  
  
  
  
  assign mst_write_req_o.ar_valid = 1'b0;
  assign mst_write_req_o.r_ready  = 1'b0;
  
  `ASSERT_NEVER(mst_write_resp_r_valid, mst_write_resp_i.r_valid, clk_i, !rst_ni)
  
  assign mst_write_req_o.aw_valid = slv_req_i.aw_valid;
  assign slv_resp_o.aw_ready      = mst_write_resp_i.aw_ready;
  
  assign mst_write_req_o.w_valid  = slv_req_i.w_valid;
  assign slv_resp_o.w_ready       = mst_write_resp_i.w_ready;
  
  assign slv_resp_o.b_valid       = mst_write_resp_i.b_valid;
  assign mst_write_req_o.b_ready  = slv_req_i.b_ready;
endmodule : TopModule
