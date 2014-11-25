require "formula"

class Samblaster < Formula
  homepage "https://github.com/GregoryFaust/samblaster"
  #doi "10.1093/bioinformatics/btu314"
  #tag "bioinformatics"

  url "https://github.com/GregoryFaust/samblaster/releases/download/v.0.1.20/samblaster-v.0.1.20.tar.gz"
  sha1 "202eef231c7d4e188a7ec1646702642ecf976037"
  head "https://github.com/GregoryFaust/samblaster"

  patch :DATA

  def install 
    #inreplace "samblaster.cpp", "sig_t", "signal_t"
    system "make"
    bin.install "samblaster"
  end

  test do
    system "samblaster --version"
  end
end
__END__
diff --git a/samblaster.cpp b/samblaster.cpp
index 14a2a40..f3408a6 100644
--- a/samblaster.cpp
+++ b/samblaster.cpp
@@ -26,6 +26,14 @@
 #include <map>
 #include "sbhash.h"
 
+// Define mempcpy for Mac OS
+#ifdef __APPLE__
+void* mempcpy(void* dst, const void* src, size_t len) {
+    return (char*)memcpy(dst, src, len) + len;
+}
+#endif
+
+
 // Rename common integer types.
 // I like having these shorter name.
 typedef uint64_t UINT64;
@@ -110,7 +118,7 @@ inline UINT64 diffTVs (struct timeval * startTV, struct timeval * endTV)
 
 // We need to pre-define these for the SAM specific fields.
 typedef UINT32 pos_t; // Type for reference offsets.
-typedef UINT64 sig_t; // Type for signatures for offsets and lengths.
+typedef UINT64 signal_t; // Type for signatures for offsets and lengths.
 // And the type itself for the next pointer.
 typedef struct splitLine splitLine_t;
 splitLine_t * splitLineFreeList = NULL;
@@ -538,13 +546,13 @@ void deleteState(state_t * s)
 // Signatures
 ///////////////////////////////////////////////////////////////////////////////
 
-inline sig_t calcSig(splitLine_t * first, splitLine_t * second)
+inline signal_t calcSig(splitLine_t * first, splitLine_t * second)
 {
     // Total nonsense to get the compiler to actually work.
     UINT64 t1 = first->pos;
     UINT64 t2 = t1 << 32;
     UINT64 final = t2 | second->pos;
-    return (sig_t)final;
+    return (signal_t)final;
 }
 
 inline int calcSigArrOff(splitLine_t * first, splitLine_t * second, seqMap_t & seqs)
@@ -840,7 +848,7 @@ void markDupsDiscordants(splitLine_t * block, state_t * state)
         if (!orphan && needSwap(first, second)) swapPtrs(&first, &second);
 
         // Now find the signature of the pair.
-        sig_t sig = calcSig(first, second);
+        signal_t sig = calcSig(first, second);
         // Calculate the offset into the signatures array.
         int off = calcSigArrOff(first, second, state->seqs);
         // Attempt insert into the sigs structure.
