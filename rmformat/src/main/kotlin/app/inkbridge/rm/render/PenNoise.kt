package app.inkbridge.rm.render

/** The firmware's 256-entry noise permutation (xochitl 0x11dd648, stored twice there), used by the pencil, ballpoint, marker and paintbrush fills. */
internal object PenNoise {
    private const val HEX =
        "177da13467754625f765cba97c7e2c7b98ee912dab72fd0ac088049df91e2348" +
        "af3f4d5ab510606f85684ba25d3842f0083254e531d2adef8d01571202c68f39" +
        "e1a03ad9a8cef5ccc706493c14e6d3e95ec858094a9b210fdb82e2ca53ec2aac" +
        "a5da37de2e6b629a6d43c4b27f9e0df3414fa6f819e073504433b880e8d0977a" +
        "1ad4692bb3d5eb9492590ec31c4e704cfa2f18fb8c6cbabee4aab78b27bcf4f6" +
        "84307790b48a86c152b6787956dcd1035bf19555cd9671d81f6429a4b1d699e7" +
        "2647b9ae61c91d5f075c36febf7622dd830ba363ea51e3939cb0118e450c6e3e" +
        "1bff00c23b74f2fc1315bb35cf8140873d28a7ed66df6a9fc5bdd78924201605"

    private val T = IntArray(512).also { t -> for (i in 0 until 256) { val v = HEX.substring(i * 2, i * 2 + 2).toInt(16); t[i] = v; t[i + 256] = v } }

    /** Lattice value at an integer point. */
    fun g(ix: Int, iy: Int): Int = T[T[iy and 255] + (ix and 255)]

    /** Value noise 0..254 at (u, v): bilinear over [g] with 8-bit fixed-point weights. */
    fun lerp2(u: Double, v: Double): Int {
        val ix = Math.floor(u).toInt(); val iy = Math.floor(v).toInt()
        val fx = ((u - ix) * 255).toInt(); val fy = ((v - iy) * 255).toInt()
        val r0 = (255 - fx) * g(ix, iy) + fx * g(ix + 1, iy)
        val r1 = (255 - fx) * g(ix, iy + 1) + fx * g(ix + 1, iy + 1)
        return ((255 - fy) * r0 + fy * r1) shr 16
    }
}
