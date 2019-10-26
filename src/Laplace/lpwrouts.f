c
cc     Plane wave routines for Laplace 3D FMM
c-------------------------------------------------------------

      subroutine rlscini(rlsc,nlambs,rlams,nterms)
      implicit double precision (a-h,o-z)
      double precision rlsc(0:nterms,0:nterms,nlambs)
      double precision     rlams(nlambs),rlampow(0:100)
      double precision     facts(0:200)
c
      facts(0) = 1.0d0
      do i = 1,100
	    facts(i) = facts(i-1)*dsqrt(i+0.0d0)
      enddo
c
      do nl = 1,nlambs
c
c     compute powers of lambda_nl
c
        rlampow(0) = 1.0d0
        rmul = rlams(nl)
        do j = 1,nterms
          rlampow(j) = rlampow(j-1)*rmul
        enddo
        do j = 0,nterms
          do k = 0,j
            rlsc(j,k,nl) = rlampow(j)/(facts(j-k)*facts(j+k))
          enddo
        enddo
      enddo

      return
      end
c-------------------------------------------------------------
      subroutine mkexps(rlams,nlambs,numphys,nexptotp,xs,ys,zs)
      implicit double precision (a-h,o-z)
      double complex ima
      double complex xs(-5:5,nexptotp)
      double complex ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision     rlams(nlambs),u
      integer  nlambs,numphys(nlambs),nexptotp
      data ima/(0.0d0,1.0d0)/
c
c     this subroutine computes the tables of exponentials needed
c     for translating exponential representations of harmonic
c     functions, discretized via normans quadratures.
c
c     u   = \int_0^\infty e^{-\lambda z}
c           \int_0^{2\pi} e^{i\lambda(x cos(u)+y sin(u))}
c           mexpphys(lambda,u) du dlambda
c
c     mexpphys(*):  discrete values of the moment function 
c                   m(\lambda,u), ordered as follows.
c
c         mexpphys(1),...,mexpphys(numphys(1)) = m(\lambda_1,0),..., 
c              m(\lambda_1, 2*pi*(numphys(1)-1)/numphys(1)).
c         mexpphys(numphys(1)+1),...,mexpphys(numphys(2)) = 
c              m(\lambda_2,0),...,
c                  m(\lambda_2, 2*pi*(numphys(2)-1)/numphys(2)).
c         etc.
c
c     on input:
c
c     rlams(nlambs)   discretization points in lambda integral 
c     nlambs          number of discret. pts. in lambda integral
c     numphys(j)     number of nodes in u integral needed 
c                    for corresponding lambda =  lambda_j. 
c     nexptotp        sum_j numphys(j)
c
c     on output:
c
c     xs(m,nexptotp)   e^{i \lambda_j (m cos(u_k)}  in above ordering
c                         for m=-5,-4,-3,-2,-1,0,1,2,3,4,5
c     ys(m,nexptotp)   e^{i \lambda_j (m sin(u_k)}  in above ordering,
c                         for m=-5,-4,-3,-2,-1,0,1,2,3,4,5
c     zs(1,nexptotp)   e^{- m \lambda_j}     in above ordering,
c                         for m=1,2,3,4,5
c------------------------------------------------------------
c      
c     loop over each lambda value 
c
      pi = 4*datan(1.0d0)
      ntot = 0
      do nl = 1,nlambs
        hu=2*pi/numphys(nl)
        do mth = 1,numphys(nl)
          u = (mth-1)*hu
          ncurrent = ntot+mth
          zs(1,ncurrent) = exp( -rlams(nl) )
          zs(2,ncurrent) = exp( - 2.0d0*rlams(nl) )
          zs(3,ncurrent) = exp( - 3.0d0*rlams(nl) )
          zs(4,ncurrent) = exp( - 4.0d0*rlams(nl) )
          zs(5,ncurrent) = exp( - 5.0d0*rlams(nl) )
          xs(1,ncurrent) = exp(ima*rlams(nl)*cos(u))
          xs(2,ncurrent) = exp(ima*rlams(nl)*2.0d0*cos(u))
          xs(3,ncurrent) = exp(ima*rlams(nl)*3.0d0*cos(u))
          xs(4,ncurrent) = exp(ima*rlams(nl)*4.0d0*cos(u))
          xs(5,ncurrent) = exp(ima*rlams(nl)*5.0d0*cos(u))
          ys(1,ncurrent) = exp(ima*rlams(nl)*sin(u))
          ys(2,ncurrent) = exp(ima*rlams(nl)*2.0d0*sin(u))
          ys(3,ncurrent) = exp(ima*rlams(nl)*3.0d0*sin(u))
          ys(4,ncurrent) = exp(ima*rlams(nl)*4.0d0*sin(u))
          ys(5,ncurrent) = exp(ima*rlams(nl)*5.0d0*sin(u))

          xs(0,ncurrent)  = 1.0d0
          xs(-1,ncurrent) = exp(-ima*rlams(nl)*cos(u))
          xs(-2,ncurrent) = exp(-ima*rlams(nl)*2.0d0*cos(u))
          xs(-3,ncurrent) = exp(-ima*rlams(nl)*3.0d0*cos(u))
          xs(-4,ncurrent) = exp(-ima*rlams(nl)*4.0d0*cos(u))
          xs(-5,ncurrent) = exp(-ima*rlams(nl)*5.0d0*cos(u))

          ys(0,ncurrent) = 1.0d0
          ys(-1,ncurrent) = exp(-ima*rlams(nl)*sin(u))
          ys(-2,ncurrent) = exp(-ima*rlams(nl)*2.0d0*sin(u))
          ys(-3,ncurrent) = exp(-ima*rlams(nl)*3.0d0*sin(u))
          ys(-4,ncurrent) = exp(-ima*rlams(nl)*4.0d0*sin(u))
          ys(-5,ncurrent) = exp(-ima*rlams(nl)*5.0d0*sin(u))
        enddo
        ntot = ntot + numphys(nl)
      enddo

      return
      end
c***********************************************************************
      subroutine mkfexp(nlambs,numfour,numphys,fexpe,fexpo,fexpback)
      implicit double precision (a-h,o-z)
      double complex ima
      double complex fexpe(1)
      double complex fexpo(1)
      double complex fexpback(1)
      integer  nlambs,numphys(nlambs),numfour(nlambs)
      data ima/(0.0d0,1.0d0)/
c
c     this subroutine computes the tables of exponentials needed
c     for mapping from fourier to physical domain. 
c     in order to minimize storage, they are organized in a 
c     one-dimenional array corresponding to the order in which they
c     are accessed by subroutine ftophys.
c    
c     size of fexpe, fexpo =          40000   for nlambs = 39
c     size of fexpe, fexpo =          15000   for nlambs = 30
c     size of fexpe, fexpo =           4000   for nlambs = 20
c     size of fexpe, fexpo =            400   for nlambs = 10
c
c***********************************************************************
      pi = 4*datan(1.0d0)
      nexte = 1
      nexto = 1
      do i=1,nlambs
	    nalpha = numphys(i)
        halpha=2*pi/nalpha
        do j=1,nalpha
          alpha=(j-1)*halpha
	      do mm = 2,numfour(i),2
            fexpe(nexte)  = cdexp(ima*(mm-1)*alpha)
	        nexte = nexte + 1
          enddo
	      do mm = 3,numfour(i),2
            fexpo(nexto)  = cdexp(ima*(mm-1)*alpha)
	        nexto = nexto + 1
          enddo
        enddo
      enddo

      next = 1
      do i=1,nlambs
	    nalpha = numphys(i)
        halpha=2*pi/nalpha
	    do mm = 2,numfour(i)
          do j=1,nalpha
            alpha=(j-1)*halpha
            fexpback(next)  = cdexp(-ima*(mm-1)*alpha)
	        next = next + 1
          enddo
        enddo
      enddo

      return
      end

c---------------------------------------------------
      subroutine mpoletoexp(nd,mpole,nterms,nlambs,numtets,nexptot,
     1                mexpupf,mexpdownf,rlsc)

c     This subroutine converts a multipole expansion into the
c     corresponding exponential moment function mexp for
c     both the +z direction and the -z direction
c
c     Note: this subroutine is the same as mpoletoexp
c     in mtxbothnew.f but just has a different data structure
c     for mpole
c
c     U(x,y,z) = \sum_{n=0}^{nterms} \sum_{m=-n,n} mpole(n,m)
c                Y_n^m (\cos(\theta)) e^{i m \phi}/r^{n+1}
c  
c              = (1/2\pi) \int_{0}^{\infty} e^{-\lambda z}
c                \int_{0}^{2\pi} e^{i \lambda (x \cos(\alpha) +
c                y \sin(\alpha))} mexpup(\lambda,\alpha)
c                d\alpha d\lambda
c 
c     for the +z direction and
c
c              = (1/2\pi) \int_{0}^{\infty} e^{\lambda z}
c                \int_{0}^{2\pi} e^{-i \lambda (x \cos(\alpha) +
c                y \sin(\alpha))} mexpdown(\lambda,\alpha)
c                d\alpha d\lambda
c 
c     for the -z direction
c
c     NOTE: The expression for -z corresponds to the mapping
c     (x,y,z) -> (-x,-y,-z), ie reflection through
c     the origin.
c
c     NOTE 2: The multipole expansion is assumed to have been
c     rescaled so that the box containing the sources has unit
c     dimension
c
c     NOTE 3: Since we store the exponential moment function in
c     Fourier domain (w.r.t the \alpha variable) we compute
c 
c     M_\lambda(m) = (i)**m \sum_{n=m}^{N} c(n,m) mpole(n,m)
c     lambda^n
c 
c     for m >=0 only, where c(n,m) = 1/sqrt((n+m)!(n-m)!)
c
c     For possible future reference, it should be noted that it
c     is NOT true that M_\lambda(-m) = dconjg(M_\lambda(m))
c
c     Inspection of the integral formula for Y_n^{-m} shows
c     that M_\lambda(-m) = dconjg(M_\lambda) * (-1)**m
c
c     INPUT arguments
c     nd          in: integer
c                 number of multipole expansions
c
c     mpole       in: double complex (nd,0:nterms, -nterms:nterms)
c                 The multipole expansion 
c  
c     nterms:     in: integer
c                 Order of the multipole expansion
c
c     nlambs      in: integer
c                 number of discretization points in the \lambda
c                 integral
c
c     numtets     in: integer(nlambs)
c                 number of fourier modes needed in expansion
c                 of \alpha variable for each \lambda variable
c
c     nexptot     in: integer
c                 nexptot = \sum_{j} numtets(j)
c
c     rlsc        in: double precision(0:nterms, 0:nterms,nlambs)
c                 scaled discretization points in the \lambda
c                 integral
c
c     OUTPUT 
c     mexpupf     out: double complex (nd,nexptot)
c                 Fourier coefficients of the function
c                 mexpup(\lambda,\alpha) for successive
c                 discrete lambda values. They are ordered as
c                 follows
c
c                 mexpupf(1,...., numtets(1)) = fourier modes
c                             for \lambda_1
c
c                 mexpupf(numtets(1)+1,...., numters(2) = fourier
c                 modes for \lambda_2
c
c                 ETC
c
c     mexpdownf   out: double complex (nd,nexptot)
c                 Fourier coefficients of the function 
c                 mexpdown(\lambda,\alpha) for successive
c                 discrete \lambda values
c---------------------------------------------------------------

      implicit none
      integer nd
      integer nterms,nlambs,numtets(nlambs),nexptot
      double complex mpole(nd,0:nterms,-nterms:nterms)
      double complex mexpupf(nd,nexptot)
      double complex mexpdownf(nd,nexptot)
      double precision rlsc(0:nterms,0:nterms,nlambs)

c     Temp variables
      double complex, allocatable :: ztmp1(:),ztmp2(:)
      double complex zeyep
      double precision sgn
      integer ntot,ncurrent,nl,mth,nm,idim

      allocate(ztmp1(nd),ztmp2(nd))

      ntot = 0
      do nl=1,nlambs
        sgn = -1.0d0
        zeyep = 1.0d0

        do mth = 0,numtets(nl)-1
          ncurrent = ntot + mth + 1

          do idim = 1,nd
            ztmp1(idim) = 0.0d0
            ztmp2(idim) = 0.0d0
          enddo

          sgn = -sgn
          do nm = mth,nterms,2
            do idim=1,nd
              ztmp1(idim) = ztmp1(idim) + 
     1            rlsc(nm,mth,nl)*mpole(idim,nm,mth)
            enddo
          enddo

          do nm=mth+1,nterms,2
            do idim=1,nd
              ztmp2(idim) = ztmp2(idim) + 
     1           rlsc(nm,mth,nl)*mpole(idim,nm,mth)
            enddo
          enddo

          do idim=1,nd
            mexpupf(idim,ncurrent) = (ztmp1(idim)+ztmp2(idim))*zeyep
            mexpdownf(idim,ncurrent) = 
     1         sgn*(ztmp1(idim)-ztmp2(idim))*zeyep
          enddo
          zeyep = zeyep*dcmplx(0.0d0,1.0d0)
        enddo
        ntot = ntot + numtets(nl)
      enddo

      return
      end

c -----------------------------------------------------------------
      subroutine exptolocal(nd,local,nterms,rlambs,whts,nlambs,numtets,
     1                     nthmax,nexptot,lexp1f,lexp2f,scale,rlsc)
c-----------------------------------------------------------------
c     INPUT arguments
c     nd               in: number of local expansions
c 
c     nterms           in: integer
c                      Order of local expansion
c
c     rlambs           in: double precision(nlambs)
c                      discretization points in the \lambda integral
c
c     whts             in: double precision(nlambs)
c                      quadrature weights in \lambda integral
c
c     nlambs           in: integer
c                      number of discretization points in \lambda
c                      integral
c
c     numtets          in: integer(nlambs)
c                      number of fourier modes in expansion of
c                      \alpha variable for \lambda_j
c
c     nthmax           in: integer
c                      max_j numtets(j)
c
c     nexptot          in: integer
c                      sum_j numtets(j)
c                      
c
c     lexp1f(nd,nexptot)  double complex(nd,nexptot)
c                      Fourier coefficients of the function 
c                      lexp1 for discrete \lambda values
c                      in the +z direction
c                      They are ordered as follows:
c
c                      lexp1f(1,...,numtets(1)) = Fourier modes
c                      for \lambda_1
c                      lexp1f(numtets(1)+1,...,numtets(2) = Fourier
c                      modes for \lambda_2 etc
c
c
c     lexp2f(nd,nexptot)  double complex(nd,nexptot)
c                      Fourier coefficients of the function 
c                      lexp1 for discrete \lambda values
c                      in the -z direction
c                      They are ordered as follows:
c
c                      lexp1f(1,...,numtets(1)) = Fourier modes
c                      for \lambda_1
c                      lexp1f(numtets(1)+1,...,numtets(2) = Fourier
c                      modes for \lambda_2 etc
c
c     scale            in: double precision
c                      scaling parameter for local expansion
c
c     rlsc        in: double precision(nlambs, 0:nterms, 0:nterms)
c                 scaled discretization points in the \lambda
c                 integral
c
c     OUTPUT
c     local(nd,0:nterms,-nterms:nterms): output local expansion of order
c                                     nterms
        
      implicit none
      integer nd
      integer nterms,nlambs,numtets(nlambs),nexptot,nthmax
      integer ncurrent,ntot,nl
      double complex local(nd,0:nterms,-nterms:nterms)
      double complex lexp1f(nd,nexptot),lexp2f(nd,nexptot)
      double complex zeye(0:nterms)
      double precision rlambs(nlambs), rlambpow(0:nterms) ,whts(nlambs)
      double precision rmul,rlsc(0:nterms,0:nterms,nlambs)
      double precision scale, rscale(0:nterms)
      double complex ima
    
c     Temporary variables
      integer i, nm, mth, j, mmax,idim
      double precision dtmp

      data ima/(0.0d0,1.0d0)/


      zeye(0) = 1.0d0
      do i=1,nterms
        zeye(i) = zeye(i-1)*ima
      enddo

      rscale(0) = 1
      do nm=0,nterms
         if(nm.gt.0) rscale(nm) = rscale(nm-1)*scale
         do mth = -nterms,nterms
           do idim=1,nd
             local(idim,nm,mth) = 0.0d0
           enddo
         enddo
      enddo

      ntot = 1
      do nl=1,nlambs
c        Add contributions to local expansion
        do nm=0,nterms,2
          mmax = numtets(nl)-1
          if(mmax.gt.nm) mmax = nm
          do mth=0,mmax
            ncurrent = ntot+mth
            dtmp = rlsc(nm,mth,nl)*whts(nl)
            do idim=1,nd
              local(idim,nm,mth) = local(idim,nm,mth)+
     1          (lexp1f(idim,ncurrent)+lexp2f(idim,ncurrent))*dtmp
            enddo
          enddo
        enddo
        do nm=1,nterms,2
          mmax = numtets(nl) - 1
          if(mmax.gt.nm) mmax = nm
          do mth =0,mmax
            ncurrent = ntot+mth
            dtmp = -rlsc(nm,mth,nl)*whts(nl)
            do idim=1,nd
              local(idim,nm,mth) = local(idim,nm,mth)+
     1          (lexp1f(idim,ncurrent)-lexp2f(idim,ncurrent))*dtmp
            enddo
          enddo
        enddo
        ntot = ntot + numtets(nl)
      enddo

      do nm=0,nterms
        do idim=1,nd
          local(idim,nm,0) = local(idim,nm,0)*zeye(0)
        enddo
        do mth = 1,nm
          do idim=1,nd
            local(idim,nm,mth) = local(idim,nm,mth)*zeye(mth)
            local(idim,nm,-mth) = dconjg(local(idim,nm,mth))
          enddo
        enddo
      enddo

      return
      end
c------------------------------------------------
      subroutine phystof(nd,mexpf,nlambs,numfour,numphys,
     1                      mexpphys,fexpback)
      implicit double precision (a-h,o-z)
      double complex mexpf(nd,*)
      double complex mexpphys(nd,*),ima
      double complex fexpback(*)
      double precision alphas(0:100),hh
      integer  nlambs,numfour(nlambs),numphys(nlambs),nthmax
      data ima/(0.0d0,1.0d0)/
c
c     this subroutine converts the discretized exponential moment function
c     into its fourier expansion.
c
c     on input:
c
c     mexpphys(nd,*):  discrete values of the moment function 
c                   m(\lambda,\alpha), ordered as follows.
c
c         mexpphys(1),...,mexpphys(numphys(1)) = m(\lambda_1,0),..., 
c              m(\lambda_1, 2*pi*(numphys(1)-1)/numphys(1)).
c         mexpphys(numphys(1)+1),...,mexpphys(numphys(2)) = 
c              m(\lambda_2,0),...,
c                  m(\lambda_2, 2*pi*(numphys(2)-1)/numphys(2)).
c         etc.
c
c     nlambs:        number of discretization pts. in lambda integral
c     numfour(j):   number of fourier modes in the expansion
c                      of the function m(\lambda_j,\alpha)
c     nthmax =      max_j numfour(j)
c
c     on output:
c
c     mexpf(nd,*):     fourier coefficients of the function 
c                   mexp(lambda,alpha) for discrete lambda values. 
c                   they are ordered as follows:
c
c               mexpf(1,...,numfour(1)) = fourier modes for lambda_1
c               mexpf(numfour(1)+1,...,numfour(2)) = fourier modes
c                                              for lambda_2
c               etc.
c
c------------------------------------------------------------
      done=1.0d0
c
c
      pi=datan(done)*4
      nftot = 0
      nptot  = 0
      next  = 1
      do i=1,nlambs
        nalpha = numphys(i)
        hh = 1.0d0/nalpha
        halpha=2*pi*hh
        do j=1,nalpha
          alphas(j)=(j-1)*halpha
        enddo

        do idim=1,nd
          mexpf(idim,nftot+1) = 0.0d0
        enddo

        do ival=1,nalpha
          do idim=1,nd
            mexpf(idim,nftot+1) = mexpf(idim,nftot+1) + 
     1          mexpphys(idim,nptot+ival)*hh 
          enddo
        enddo

        do mm = 2,numfour(i)
          do idim=1,nd
            mexpf(idim,nftot+mm) = 0.0d0 
          enddo
          do ival=1,nalpha
            do idim=1,nd
              mexpf(idim,nftot+mm) = mexpf(idim,nftot+mm)+
     1          fexpback(next)*mexpphys(idim,nptot+ival)*hh
            enddo
            next = next+1
          enddo
        enddo
        nftot = nftot+numfour(i)
        nptot = nptot+numphys(i)
      enddo

      return
      end
c
c------------------------------------------------

c
      subroutine ftophys(nd,mexpf,nlambs,rlams,numfour,numphys,
     1                      nthmax,mexpphys,fexpe,fexpo)
      implicit double precision (a-h,o-z)
      double complex mexpf(nd,*)
      double complex mexpphys(nd,*),ima,ctmp
      double complex fexpe(*)
      double complex fexpo(*)
      double precision     rlams(nlambs)
      double precision     alphas(0:200)
      integer  nlambs,numfour(nlambs),numphys(nlambs),nthmax
      data ima/(0.0d0,1.0d0)/
c
c     this subroutine evaluates the fourier expansion of the
c     exponential moment function m(\lambda,\alpha) at equispaced
c     nodes.
c
c     on input:
c
c     mexpf(nd,*):     fourier coefficients of the function 
c                   mexp(lambda,alpha) for discrete lambda values. 
c                   they are ordered as follows:
c
c               mexpf(1,...,numfour(1)) = fourier modes for lambda_1
c               mexpf(numfour(1)+1,...,numfour(2)) = fourier modes
c                                              for lambda_2
c               etc.
c
c     nlambs:        number of discretization pts. in lambda integral
c     rlams(nlambs): discretization points in lambda integral.
c     numfour(j):   number of fourier modes in the expansion
c                      of the function m(\lambda_j,\alpha)
c     nthmax =      max_j numfour(j)
c     fexpe =      precomputed array of exponentials needed for
c                  fourier series evaluation
c     fexpo =      precomputed array of exponentials needed for
c                  fourier series evaluation
c
c     on output:
c
c     mexpphys(nd,*):  discrete values of the moment function 
c                   m(\lambda,\alpha), ordered as follows.
c
c         mexpphys(1),...,mexpphys(numphys(1)) = m(\lambda_1,0),..., 
c              m(\lambda_1, 2*pi*(numphys(1)-1)/numphys(1)).
c         mexpphys(numphys(1)+1),...,mexpphys(numphys(2)) = 
c              m(\lambda_2,0),...,
c                  m(\lambda_2, 2*pi*(numphys(2)-1)/numphys(2)).
c         etc.
c
c------------------------------------------------------------
      done=1.0d0
c
c
      pi=datan(done)*4
      nftot = 0
      nptot  = 0
      nexte = 1
      nexto = 1
      do i=1,nlambs
        do ival=1,numphys(i)
          do idim=1,nd
            mexpphys(idim,nptot+ival) = mexpf(idim,nftot+1)
          enddo
          do mm = 2,numfour(i),2
            do idim=1,nd
              rtmp = 2*imag(fexpe(nexte)*mexpf(idim,nftot+mm))
              mexpphys(idim,nptot+ival) = mexpphys(idim,nptot+ival) +
     1                dcmplx(0.0d0,rtmp)
            enddo
            nexte = nexte + 1
          enddo
          do mm = 3,numfour(i),2
            do idim=1,nd
              rtmp = 2*real(fexpo(nexto)*mexpf(idim,nftot+mm))
              mexpphys(idim,nptot+ival) = mexpphys(idim,nptot+ival) +
     1                rtmp
            enddo
            nexto = nexto + 1
          enddo
        enddo
        nftot = nftot+numfour(i)
        nptot = nptot+numphys(i)
      enddo

      return
      end
c
c
c--------------------------------------------------------------------
      subroutine processudexp(nd,ibox,ilev,nboxes,centers,ichild,
     1           rscale,nterms,iaddr,rmlexp,rlams,whts,nlams,nfourier,
     2           nphysical,nthmax,nexptot,nexptotp,mexp,nuall,uall,
     3           nu1234,u1234,ndall,dall,nd5678,d5678,mexpup,mexpdown,
     4           mexpupphys,mexpdownphys,mexpuall,mexpu5678,mexpdall,
     5           mexpd1234,xs,ys,zs,fexpback,rlsc,rscpow)
c--------------------------------------------------------------------
c      process up down expansions for box ibox
c-------------------------------------------------------------------
      implicit none
      integer idim,nd
      integer ibox,ilev,nboxes,nterms,nlams,nthmax
      integer nphysical(nlams),nfourier(nlams)
      integer *8 iaddr(2,nboxes)
      integer ichild(8,nboxes)
      integer nexptot,nexptotp,nmax
      integer nuall,ndall,nu1234,nd5678
      integer uall(*),dall(*),u1234(*),d5678(*)
      double precision rscale
      double precision rlams(*),whts(*)
      double complex, allocatable :: tloc(:,:,:)  
      double complex mexp(nd,nexptotp,nboxes,6)
      double precision rmlexp(*),centers(3,*)
      double complex mexpup(nd,nexptot),mexpdown(nd,nexptot)
      double complex mexpupphys(nd,nexptotp),mexpdownphys(nd,nexptotp)
      double complex mexpuall(nd,nexptotp),mexpdall(nd,nexptotp)
      double complex mexpd1234(nd,nexptotp),mexpu5678(nd,nexptotp)
      double complex xs(-5:5,nexptotp),ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision rlsc(0:nterms,0:nterms,nlams),rscpow(0:nterms)
      double complex fexpback(*)

c      temp variables
      integer jbox,ctr,ii,jj,i,ix,iy,iz,j
      double precision rtmp,rtmp2
      double complex ztmp,zmul,ztmp2
     
      double precision ctmp(3)

      allocate(tloc(nd,0:nterms,-nterms:nterms))


      do i=1,nexptotp
        do idim=1,nd
          mexpuall(idim,i) = 0
          mexpdall(idim,i) = 0
          mexpu5678(idim,i) = 0
          mexpd1234(idim,i) = 0
        enddo
      enddo
      
   
      ctmp(1) = centers(1,ibox) - rscale/2.0d0
      ctmp(2) = centers(2,ibox) - rscale/2.0d0
      ctmp(3) = centers(3,ibox) - rscale/2.0d0
       
      do i=1,nuall
        jbox = uall(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iz,j)*xs(ix,j)*ys(iy,j)
          do idim=1,nd
            mexpdall(idim,j) = mexpdall(idim,j) + 
     1          mexp(idim,j,jbox,2)*zmul
          enddo
        enddo
      enddo

      do i=1,nu1234
        jbox = u1234(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale

        do j=1,nexptotp
          zmul = zs(iz,j)*xs(ix,j)*ys(iy,j)
          do idim=1,nd
            mexpd1234(idim,j) = mexpd1234(idim,j) + 
     1          mexp(idim,j,jbox,2)*zmul
          enddo
        enddo
      enddo


      do i=1,ndall
        jbox = dall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale

        do j=1,nexptotp
          zmul = zs(-iz,j)*xs(-ix,j)*ys(-iy,j)
          do idim=1,nd
            mexpuall(idim,j) = mexpuall(idim,j) + 
     1          mexp(idim,j,jbox,1)*zmul
          enddo
        enddo
      enddo

      do i=1,nd5678
        jbox = d5678(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale

        do j=1,nexptotp
          zmul = zs(-iz,j)*xs(-ix,j)*ys(-iy,j)
          do idim=1,nd
            mexpu5678(idim,j) = mexpu5678(idim,j) + 
     1         mexp(idim,j,jbox,1)*zmul
          enddo
        enddo
      enddo

c
cc       move contributions to the children
c


c      add contributions due to child 1

      jbox = ichild(1,ibox)

      if(jbox.gt.0) then
        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)
            mexpdownphys(idim,i) = mexpdall(idim,i) + mexpd1234(idim,i)
          enddo
        enddo

       call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
       call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

c
c         NOTE: fix rscpow to be 1/rscpow
c
        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 2
      jbox = ichild(2,ibox)
      if(jbox.gt.0) then
        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*xs(1,i)
            mexpdownphys(idim,i) = (mexpdall(idim,i) + 
     1          mexpd1234(idim,i))*xs(-1,i)
          enddo
        enddo
 
        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif
  
c      add contributions due to child 3
      jbox = ichild(3,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*ys(1,i)
            mexpdownphys(idim,i) = (mexpdall(idim,i) + 
     1          mexpd1234(idim,i))*ys(-1,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 4
      jbox = ichild(4,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*xs(1,i)
          ztmp2 = ys(-1,i)*xs(-1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*ztmp
            mexpdownphys(idim,i) = (mexpdall(idim,i) + 
     1         mexpd1234(idim,i))*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 5
      jbox = ichild(5,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          rtmp = 1.0d0/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpuall(idim,i)+
     1           mexpu5678(idim,i))*zs(1,i)
            mexpdownphys(idim,i) = mexpdall(idim,i)*rtmp
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 6
      jbox = ichild(6,ibox)

      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(1,i)*zs(1,i)
          ztmp2 = xs(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpuall(idim,i)+
     1         mexpu5678(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)


      endif

c      add contributions due to child 7
 
      jbox = ichild(7,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = zs(1,i)*ys(1,i)
          ztmp2 = ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpuall(idim,i)+
     1          mexpu5678(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 8
      jbox = ichild(8,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = zs(1,i)*ys(1,i)*xs(1,i)
          ztmp2 = xs(-1,i)*ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpuall(idim,i)+
     1         mexpu5678(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

      return
      end
c--------------------------------------------------------------------      

      subroutine processnsexp(nd,ibox,ilev,nboxes,centers,ichild,
     1           rscale,nterms,iaddr,rmlexp,rlams,whts,nlams,nfourier,
     2           nphysical,nthmax,nexptot,nexptotp,mexp,nnall,nall,
     3           nn1256,n1256,nn12,n12,nn56,n56,
     4           nsall,sall,ns3478,s3478,ns34,s34,ns78,s78,mexpup,
     5           mexpdown,mexpupphys,mexpdownphys,
     6           mexpnall,mexpn3478,mexpn34,mexpn78,mexpsall,
     7           mexps1256,mexps12,mexps56,rdplus,
     8           xs,ys,zs,fexpback,rlsc,rscpow)
c--------------------------------------------------------------------
c      create up down expansions for box ibox
c-------------------------------------------------------------------
      implicit none
      integer nd
      integer ibox,ilev,nboxes,nterms,nlams,nthmax
      integer nphysical(nlams),nfourier(nlams)
      integer *8 iaddr(2,nboxes)
      integer ichild(8,nboxes)
      integer nexptot,nexptotp,nmax
      integer nnall,nsall,nn1256,ns3478,nn12,nn56,ns34,ns78
      integer nall(*),sall(*),n1256(*),s3478(*)
      integer n12(*),n56(*),s34(*),s78(*)
      double precision rscale
      double complex zk2
      double precision rlams(*),whts(*)
      double complex, allocatable :: tloc(:,:,:)
      double complex, allocatable :: tloc2(:,:,:)
      double complex mexp(nd,nexptotp,nboxes,6)
      double precision rdplus(0:nterms,0:nterms,-nterms:nterms)
      double precision rmlexp(*),centers(3,*)
      double complex mexpup(nd,nexptot),mexpdown(nd,nexptot)
      double complex mexpupphys(nd,nexptotp),mexpdownphys(nd,nexptotp)
      double complex mexpnall(nd,nexptotp),mexpsall(nd,nexptotp)
      double complex mexps1256(nd,nexptotp),mexpn3478(nd,nexptotp)
      double complex mexps12(nd,nexptotp),mexps56(nd,nexptotp)
      double complex mexpn34(nd,nexptotp),mexpn78(nd,nexptotp)
      double complex xs(-5:5,nexptotp),ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision rlsc(0:nterms,0:nterms,nlams),rscpow(0:nterms)
      double complex fexpback(*)

c      temp variables
      integer jbox,ctr,ii,jj,i,ix,iy,iz,j,idim
      double complex ztmp,zmul,ztmp2
      double precision rtmp,rtmp2
    
      double precision ctmp(3)
      allocate(tloc(nd,0:nterms,-nterms:nterms))
      allocate(tloc2(nd,0:nterms,-nterms:nterms))


      do i=1,nexptotp
        do idim=1,nd
          mexpnall(idim,i) = 0
          mexpsall(idim,i) = 0
          mexpn3478(idim,i) = 0
          mexpn34(idim,i) = 0
          mexpn78(idim,i) = 0
          mexps1256(idim,i) = 0
          mexps12(idim,i) = 0
          mexps56(idim,i) = 0
        enddo
      enddo
      
   
      ctmp(1) = centers(1,ibox) - rscale/2.0d0
      ctmp(2) = centers(2,ibox) - rscale/2.0d0
      ctmp(3) = centers(3,ibox) - rscale/2.0d0
       
      do i=1,nnall
        jbox = nall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
           zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
           do idim=1,nd
             mexpsall(idim,j) = mexpsall(idim,j) + 
     1           mexp(idim,j,jbox,4)*zmul
           enddo
        enddo

      enddo

      do i=1,nn1256
        jbox = n1256(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
          do idim=1,nd
            mexps1256(idim,j) = mexps1256(idim,j) + 
     1          mexp(idim,j,jbox,4)*zmul
          enddo
        enddo
      enddo

      do i=1,nn12
        jbox = n12(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
          do idim=1,nd
            mexps12(idim,j) = mexps12(idim,j)+mexp(idim,j,jbox,4)*zmul
          enddo
        enddo
      enddo


      do i=1,nn56
        jbox = n56(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
          do idim=1,nd
            mexps56(idim,j) = mexps56(idim,j)+mexp(idim,j,jbox,4)*zmul
          enddo
        enddo
      enddo


      do i=1,nsall
        jbox = sall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpnall(idim,j) = mexpnall(idim,j) + 
     1         mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

      do i=1,ns3478
        jbox = s3478(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpn3478(idim,j) = mexpn3478(idim,j) + 
     1         mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

      do i=1,ns34
        jbox = s34(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpn34(idim,j) = mexpn34(idim,j)+mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

      do i=1,ns78
        jbox = s78(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpn78(idim,j) = mexpn78(idim,j)+mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

c
cc       move contributions to the children
c


c      add contributions due to child 1
      jbox = ichild(1,ibox)

      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)
            mexpdownphys(idim,i) = mexpsall(idim,i)+mexps1256(idim,i)+ 
     1         mexps12(idim,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 2
      jbox = ichild(2,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)*ys(1,i)
            mexpdownphys(idim,i) = (mexpsall(idim,i) + 
     1         mexps1256(idim,i) + mexps12(idim,i))*ys(-1,i)      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)


      endif
  
c      add contributions due to child 3
      jbox = ichild(3,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          rtmp = 1/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn34(idim,i)+
     1          mexpn3478(idim,i))*zs(1,i)
            mexpdownphys(idim,i) = mexpsall(idim,i)*rtmp
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 4
      jbox = ichild(4,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*zs(1,i)
          ztmp2 = ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn34(idim,i)+
     1         mexpn3478(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpsall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 5
      jbox = ichild(5,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)*xs(1,i)
            mexpdownphys(idim,i) = (mexpsall(idim,i) + 
     1          mexps1256(idim,i) + mexps56(idim,i))*xs(-1,i)      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 6
      jbox = ichild(6,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*xs(1,i)
          ztmp2 = ys(-1,i)*xs(-1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)*ztmp
            mexpdownphys(idim,i) = (mexpsall(idim,i) + 
     1          mexps1256(idim,i) + mexps56(idim,i))*ztmp2      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 7
 
      jbox = ichild(7,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(1,i)*zs(1,i)
          ztmp2 = xs(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn78(idim,i)+
     1          mexpn3478(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpsall(idim,i)*ztmp2      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 8
      jbox = ichild(8,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*zs(1,i)*xs(1,i)
          ztmp2 = ys(-1,i)*xs(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn78(idim,i)+
     1         mexpn3478(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpsall(idim,i)*ztmp2      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)


        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

      return
      end
c--------------------------------------------------------------------      

      subroutine processewexp(nd,ibox,ilev,nboxes,centers,ichild,
     1           rscale,nterms,iaddr,rmlexp,rlams,whts,nlams,nfourier,
     2           nphysical,nthmax,nexptot,nexptotp,mexp,neall,eall,
     3           ne1357,e1357,ne13,e13,ne57,e57,ne1,e1,ne3,e3,ne5,e5,
     4           ne7,e7,nwall,wall,nw2468,w2468,nw24,w24,nw68,w68,
     5           nw2,w2,nw4,w4,nw6,w6,nw8,w8,
     6           mexpup,mexpdown,mexpupphys,mexpdownphys,
     7           mexpeall,mexpe2468,mexpe24,mexpe68,mexpe2,mexpe4,
     8           mexpe6,mexpe8,mexpwall,mexpw1357,mexpw13,mexpw57,
     9           mexpw1,mexpw3,mexpw5,mexpw7,rdminus,
     9           xs,ys,zs,fexpback,rlsc,rscpow)
c--------------------------------------------------------------------
c      create up down expansions for box ibox
c-------------------------------------------------------------------
      implicit none
      integer nd
      integer ibox,ilev,nboxes,nterms,nlams,nthmax
      integer nphysical(nlams),nfourier(nlams)
      integer *8 iaddr(2,nboxes)
      integer ichild(8,nboxes)
      integer nexptot,nexptotp,nmax
      integer neall,nwall,ne1357,nw2468,ne13,ne57,nw24,nw68
      integer ne1,ne3,ne5,ne7,nw2,nw4,nw6,nw8
      integer eall(*),wall(*),e1357(*),w2468(*)
      integer e13(*),e57(*),w24(*),w68(*)
      integer e1(*),e3(*),e5(*),e7(*),w2(*),w4(*),w6(*),w8(*)
      double precision rscale
      double complex zk2
      double precision rlams(*),whts(*)
      double complex, allocatable :: tloc(:,:,:),tloc2(:,:,:)
      double complex mexp(nd,nexptotp,nboxes,6)
      double precision rdminus(0:nterms,0:nterms,-nterms:nterms)
      double precision rmlexp(*),centers(3,*)
      double complex mexpup(nd,nexptot),mexpdown(nexptot)
      double complex mexpupphys(nd,nexptotp),mexpdownphys(nd,nexptotp)
      double complex mexpeall(nd,nexptotp),mexpwall(nd,nexptotp)
      double complex mexpw1357(nd,nexptotp),mexpe2468(nd,nexptotp)
      double complex mexpw13(nd,nexptotp),mexpw57(nd,nexptotp)
      double complex mexpe24(nd,nexptotp),mexpe68(nd,nexptotp)
      double complex mexpw1(nd,nexptotp),mexpw3(nd,nexptotp)
      double complex mexpw5(nd,nexptotp),mexpw7(nd,nexptotp)
      double complex mexpe2(nd,nexptotp),mexpe4(nd,nexptotp)
      double complex mexpe6(nd,nexptotp),mexpe8(nd,nexptotp)
      double complex xs(-5:5,nexptotp),ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision rlsc(0:nterms,0:nterms,nlams),rscpow(0:nterms)
      double complex fexpback(*)

c      temp variables
      integer jbox,ctr,ii,jj,i,ix,iy,iz,j,l,idim
      double complex ztmp,zmul,ztmp2
      double precision rtmp,rtmp2
     
      double precision ctmp(3)

      allocate(tloc(nd,0:nterms,-nterms:nterms))
      allocate(tloc2(nd,0:nterms,-nterms:nterms))


      do i=1,nexptotp
        do idim=1,nd
          mexpeall(idim,i) = 0
          mexpwall(idim,i) = 0
          mexpe2468(idim,i) = 0
          mexpe24(idim,i) = 0
          mexpe68(idim,i) = 0
          mexpe2(idim,i) = 0
          mexpe4(idim,i) = 0
          mexpe6(idim,i) = 0
          mexpe8(idim,i) = 0
          mexpw1357(idim,i) = 0
          mexpw13(idim,i) = 0
          mexpw57(idim,i) = 0
          mexpw1(idim,i) = 0
          mexpw3(idim,i) = 0
          mexpw5(idim,i) = 0
          mexpw7(idim,i) = 0
        enddo
      enddo
      
   
      ctmp(1) = centers(1,ibox) - rscale/2.0d0
      ctmp(2) = centers(2,ibox) - rscale/2.0d0
      ctmp(3) = centers(3,ibox) - rscale/2.0d0
       
      do i=1,neall
        jbox = eall(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpwall(idim,j) = mexpwall(idim,j) + 
     1         mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne1357
        jbox = e1357(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw1357(idim,j) = mexpw1357(idim,j) + 
     1         mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne13
        jbox = e13(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw13(idim,j) = mexpw13(idim,j)+mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo


      do i=1,ne57
        jbox = e57(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw57(idim,j) = mexpw57(idim,j)+mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne1
        jbox = e1(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw1(idim,j) = mexpw1(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo


      do i=1,ne3
        jbox = e3(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
             mexpw3(idim,j) = mexpw3(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne5
        jbox = e5(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
             mexpw5(idim,j) = mexpw5(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo


      do i=1,ne7
        jbox = e7(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw7(idim,j) = mexpw7(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,nwall
        jbox = wall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale

         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpeall(idim,j) = mexpeall(idim,j) + 
     1         mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw2468
        jbox = w2468(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe2468(idim,j) = mexpe2468(idim,j) + 
     1          mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw24
        jbox = w24(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe24(idim,j) = mexpe24(idim,j)+mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

       

      do i=1,nw68
        jbox = w68(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe68(idim,j) = mexpe68(idim,j)+mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw2
        jbox = w2(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe2(idim,j) = mexpe2(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo


      do i=1,nw4
        jbox = w4(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe4(idim,j) = mexpe4(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw6
        jbox = w6(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe6(idim,j) = mexpe6(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw8
        jbox = w8(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe8(idim,j) = mexpe8(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

c
cc       move contributions to the children
c


c      add contributions due to child 1
      jbox = ichild(1,ibox)

      if(jbox.gt.0) then
        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)
            mexpdownphys(idim,i) = mexpwall(idim,i)+mexpw1357(idim,i)+
     1         mexpw13(idim,i)+mexpw1(idim,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 2
      jbox = ichild(2,ibox)

      if(jbox.gt.0) then

        do i=1,nexptotp
          rtmp = 1/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1         mexpe24(idim,i)+mexpe2(idim,i))*zs(1,i)      
            mexpdownphys(idim,i) = mexpwall(idim,i)*rtmp
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif
  
c      add contributions due to child 3
      jbox = ichild(3,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)*ys(1,i)
            mexpdownphys(idim,i) = (mexpwall(idim,i)+mexpw1357(idim,i)+
     1         mexpw13(idim,i)+mexpw3(idim,i))*ys(-1,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 4
      jbox = ichild(4,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = zs(1,i)*ys(1,i)
          ztmp2 = ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1         mexpe24(idim,i)+mexpe4(idim,i))*ztmp      
            mexpdownphys(idim,i) = mexpwall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 5
      jbox = ichild(5,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)*xs(-1,i)
            mexpdownphys(idim,i) = (mexpwall(idim,i)+mexpw1357(idim,i)+
     1             mexpw57(idim,i)+mexpw5(idim,i))*xs(1,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 6
      jbox = ichild(6,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(-1,i)*zs(1,i)
          ztmp2 = xs(1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1           mexpe68(idim,i)+mexpe6(idim,i))*ztmp      
            mexpdownphys(idim,i) = mexpwall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 7
 
      jbox = ichild(7,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(-1,i)*ys(1,i)
          ztmp2 = xs(1,i)*ys(-1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)*ztmp
            mexpdownphys(idim,i) = (mexpwall(idim,i)+mexpw1357(idim,i)+
     1          mexpw57(idim,i)+mexpw7(idim,i))*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 8
      jbox = ichild(8,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(-1,i)*ys(1,i)*zs(1,i)
          ztmp2 = xs(1,i)*ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1         mexpe68(idim,i)+mexpe8(idim,i))*ztmp      
            mexpdownphys(idim,i) = mexpwall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

      return
      end
c--------------------------------------------------------------------      
c
c
c--------------------------------------------------------------------
      subroutine processlist3udexp(nd,ibox,nboxes,centers,
     1           rscale,nterms,rmlexp,rlams,whts,nlams,nfourier,
     2           nphysical,nthmax,nexptot,nexptotp,mexp,nuall,uall,
     3           ndall,dall,mexpup,mexpdown,
     4           mexpupphys,mexpdownphys,mexpuall,mexpdall,
     5           xs,ys,zs,fexpback,rlsc,rscpow)
c--------------------------------------------------------------------
c      process up down expansions for box ibox
c-------------------------------------------------------------------
      implicit none
      integer idim,nd
      integer ibox,nboxes,nterms,nlams,nthmax
      integer nphysical(nlams),nfourier(nlams)
      integer nexptot,nexptotp
      integer nuall,ndall
      integer uall(*),dall(*)
      double precision rscale
      double precision rlams(*),whts(*)
      double complex, allocatable :: tloc(:,:,:)  
      double complex mexp(nd,nexptotp,nboxes,6)
      double precision rmlexp(*),centers(3,*)
      double complex mexpup(nd,nexptot),mexpdown(nd,nexptot)
      double complex mexpupphys(nd,nexptotp),mexpdownphys(nd,nexptotp)
      double complex mexpuall(nd,nexptotp),mexpdall(nd,nexptotp)
      double complex xs(-5:5,nexptotp),ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision rlsc(0:nterms,0:nterms,nlams),rscpow(0:nterms)
      double complex fexpback(*)

c      temp variables
      integer jbox,ctr,ii,jj,i,ix,iy,iz,j
      double precision rtmp,rtmp2
      double complex ztmp,zmul,ztmp2
     
      double precision ctmp(3)

      allocate(tloc(nd,0:nterms,-nterms:nterms))


      do i=1,nexptotp
        do idim=1,nd
          mexpuall(idim,i) = 0
          mexpdall(idim,i) = 0
        enddo
      enddo
      
   
      ctmp(1) = centers(1,ibox) - rscale/2.0d0
      ctmp(2) = centers(2,ibox) - rscale/2.0d0
      ctmp(3) = centers(3,ibox) - rscale/2.0d0
       
      do i=1,nuall
        jbox = uall(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iz,j)*xs(ix,j)*ys(iy,j)
          do idim=1,nd
            mexpdall(idim,j) = mexpdall(idim,j) + 
     1          mexp(idim,j,jbox,2)*zmul
          enddo
        enddo
      enddo

      do i=1,ndall
        jbox = dall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale

        do j=1,nexptotp
          zmul = zs(-iz,j)*xs(-ix,j)*ys(-iy,j)
          do idim=1,nd
            mexpuall(idim,j) = mexpuall(idim,j) + 
     1          mexp(idim,j,jbox,1)*zmul
          enddo
        enddo
      enddo

c
cc       move contributions to the children
c


c      add contributions due to child 1

      jbox = ichild(1,ibox)

      if(jbox.gt.0) then
        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)
            mexpdownphys(idim,i) = mexpdall(idim,i)
          enddo
        enddo

       call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
       call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

c
c         NOTE: fix rscpow to be 1/rscpow
c
        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp,nterms)

      endif

c      add contributions due to child 2
      jbox = ichild(2,ibox)
      if(jbox.gt.0) then
        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*xs(1,i)
            mexpdownphys(idim,i) = mexpdall(idim,i)*xs(-1,i)
          enddo
        enddo
 
        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif
  
c      add contributions due to child 3
      jbox = ichild(3,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*ys(1,i)
            mexpdownphys(idim,i) = mexpdall(idim,i)*ys(-1,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 4
      jbox = ichild(4,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*xs(1,i)
          ztmp2 = ys(-1,i)*xs(-1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 5
      jbox = ichild(5,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          rtmp = 1.0d0/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpuall(idim,i)*zs(1,i)
            mexpdownphys(idim,i) = mexpdall(idim,i)*rtmp
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 6
      jbox = ichild(6,ibox)

      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(1,i)*zs(1,i)
          ztmp2 = xs(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  =  mexpuall(idim,i)*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)


      endif

c      add contributions due to child 7
 
      jbox = ichild(7,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = zs(1,i)*ys(1,i)
          ztmp2 = ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  =  mexpuall(idim,i)*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 8
      jbox = ichild(8,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = zs(1,i)*ys(1,i)*xs(1,i)
          ztmp2 = xs(-1,i)*ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  =  mexpuall(idim,i)+*ztmp
            mexpdownphys(idim,i) = mexpdall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call mpscale(nd,nterms,tloc,rscpow,tloc)
        call mpadd(nd,tloc,rmlexp(iaddr(2,jbox)),nterms)

      endif

      return
      end
c--------------------------------------------------------------------      

      subroutine processlist3nsexp(nd,ibox,ilev,nboxes,centers,ichild,
     1           rscale,nterms,iaddr,rmlexp,rlams,whts,nlams,nfourier,
     2           nphysical,nthmax,nexptot,nexptotp,mexp,nnall,nall,
     3           nn1256,n1256,nn12,n12,nn56,n56,
     4           nsall,sall,ns3478,s3478,ns34,s34,ns78,s78,mexpup,
     5           mexpdown,mexpupphys,mexpdownphys,
     6           mexpnall,mexpn3478,mexpn34,mexpn78,mexpsall,
     7           mexps1256,mexps12,mexps56,rdplus,
     8           xs,ys,zs,fexpback,rlsc,rscpow)
c--------------------------------------------------------------------
c      create up down expansions for box ibox
c-------------------------------------------------------------------
      implicit none
      integer nd
      integer ibox,ilev,nboxes,nterms,nlams,nthmax
      integer nphysical(nlams),nfourier(nlams)
      integer *8 iaddr(2,nboxes)
      integer ichild(8,nboxes)
      integer nexptot,nexptotp,nmax
      integer nnall,nsall,nn1256,ns3478,nn12,nn56,ns34,ns78
      integer nall(*),sall(*),n1256(*),s3478(*)
      integer n12(*),n56(*),s34(*),s78(*)
      double precision rscale
      double complex zk2
      double precision rlams(*),whts(*)
      double complex, allocatable :: tloc(:,:,:)
      double complex, allocatable :: tloc2(:,:,:)
      double complex mexp(nd,nexptotp,nboxes,6)
      double precision rdplus(0:nterms,0:nterms,-nterms:nterms)
      double precision rmlexp(*),centers(3,*)
      double complex mexpup(nd,nexptot),mexpdown(nd,nexptot)
      double complex mexpupphys(nd,nexptotp),mexpdownphys(nd,nexptotp)
      double complex mexpnall(nd,nexptotp),mexpsall(nd,nexptotp)
      double complex mexps1256(nd,nexptotp),mexpn3478(nd,nexptotp)
      double complex mexps12(nd,nexptotp),mexps56(nd,nexptotp)
      double complex mexpn34(nd,nexptotp),mexpn78(nd,nexptotp)
      double complex xs(-5:5,nexptotp),ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision rlsc(0:nterms,0:nterms,nlams),rscpow(0:nterms)
      double complex fexpback(*)

c      temp variables
      integer jbox,ctr,ii,jj,i,ix,iy,iz,j,idim
      double complex ztmp,zmul,ztmp2
      double precision rtmp,rtmp2
    
      double precision ctmp(3)
      allocate(tloc(nd,0:nterms,-nterms:nterms))
      allocate(tloc2(nd,0:nterms,-nterms:nterms))


      do i=1,nexptotp
        do idim=1,nd
          mexpnall(idim,i) = 0
          mexpsall(idim,i) = 0
          mexpn3478(idim,i) = 0
          mexpn34(idim,i) = 0
          mexpn78(idim,i) = 0
          mexps1256(idim,i) = 0
          mexps12(idim,i) = 0
          mexps56(idim,i) = 0
        enddo
      enddo
      
   
      ctmp(1) = centers(1,ibox) - rscale/2.0d0
      ctmp(2) = centers(2,ibox) - rscale/2.0d0
      ctmp(3) = centers(3,ibox) - rscale/2.0d0
       
      do i=1,nnall
        jbox = nall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
           zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
           do idim=1,nd
             mexpsall(idim,j) = mexpsall(idim,j) + 
     1           mexp(idim,j,jbox,4)*zmul
           enddo
        enddo

      enddo

      do i=1,nn1256
        jbox = n1256(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
          do idim=1,nd
            mexps1256(idim,j) = mexps1256(idim,j) + 
     1          mexp(idim,j,jbox,4)*zmul
          enddo
        enddo
      enddo

      do i=1,nn12
        jbox = n12(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
          do idim=1,nd
            mexps12(idim,j) = mexps12(idim,j)+mexp(idim,j,jbox,4)*zmul
          enddo
        enddo
      enddo


      do i=1,nn56
        jbox = n56(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(iy,j)*xs(iz,j)*ys(ix,j)
          do idim=1,nd
            mexps56(idim,j) = mexps56(idim,j)+mexp(idim,j,jbox,4)*zmul
          enddo
        enddo
      enddo


      do i=1,nsall
        jbox = sall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpnall(idim,j) = mexpnall(idim,j) + 
     1         mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

      do i=1,ns3478
        jbox = s3478(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpn3478(idim,j) = mexpn3478(idim,j) + 
     1         mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

      do i=1,ns34
        jbox = s34(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpn34(idim,j) = mexpn34(idim,j)+mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

      do i=1,ns78
        jbox = s78(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-iy,j)*xs(-iz,j)*ys(-ix,j)
          do idim=1,nd
            mexpn78(idim,j) = mexpn78(idim,j)+mexp(idim,j,jbox,3)*zmul
          enddo
        enddo
      enddo

c
cc       move contributions to the children
c


c      add contributions due to child 1
      jbox = ichild(1,ibox)

      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)
            mexpdownphys(idim,i) = mexpsall(idim,i)+mexps1256(idim,i)+ 
     1         mexps12(idim,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 2
      jbox = ichild(2,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)*ys(1,i)
            mexpdownphys(idim,i) = (mexpsall(idim,i) + 
     1         mexps1256(idim,i) + mexps12(idim,i))*ys(-1,i)      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)


      endif
  
c      add contributions due to child 3
      jbox = ichild(3,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          rtmp = 1/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn34(idim,i)+
     1          mexpn3478(idim,i))*zs(1,i)
            mexpdownphys(idim,i) = mexpsall(idim,i)*rtmp
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 4
      jbox = ichild(4,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*zs(1,i)
          ztmp2 = ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn34(idim,i)+
     1         mexpn3478(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpsall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 5
      jbox = ichild(5,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)*xs(1,i)
            mexpdownphys(idim,i) = (mexpsall(idim,i) + 
     1          mexps1256(idim,i) + mexps56(idim,i))*xs(-1,i)      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 6
      jbox = ichild(6,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*xs(1,i)
          ztmp2 = ys(-1,i)*xs(-1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpnall(idim,i)*ztmp
            mexpdownphys(idim,i) = (mexpsall(idim,i) + 
     1          mexps1256(idim,i) + mexps56(idim,i))*ztmp2      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 7
 
      jbox = ichild(7,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(1,i)*zs(1,i)
          ztmp2 = xs(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn78(idim,i)+
     1          mexpn3478(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpsall(idim,i)*ztmp2      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 8
      jbox = ichild(8,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = ys(1,i)*zs(1,i)*xs(1,i)
          ztmp2 = ys(-1,i)*xs(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpnall(idim,i)+mexpn78(idim,i)+
     1         mexpn3478(idim,i))*ztmp
            mexpdownphys(idim,i) = mexpsall(idim,i)*ztmp2      
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotytoz(nd,nterms,tloc,tloc2,rdplus)


        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

      return
      end
c--------------------------------------------------------------------      

      subroutine processlist3ewexp(nd,ibox,ilev,nboxes,centers,ichild,
     1           rscale,nterms,iaddr,rmlexp,rlams,whts,nlams,nfourier,
     2           nphysical,nthmax,nexptot,nexptotp,mexp,neall,eall,
     3           ne1357,e1357,ne13,e13,ne57,e57,ne1,e1,ne3,e3,ne5,e5,
     4           ne7,e7,nwall,wall,nw2468,w2468,nw24,w24,nw68,w68,
     5           nw2,w2,nw4,w4,nw6,w6,nw8,w8,
     6           mexpup,mexpdown,mexpupphys,mexpdownphys,
     7           mexpeall,mexpe2468,mexpe24,mexpe68,mexpe2,mexpe4,
     8           mexpe6,mexpe8,mexpwall,mexpw1357,mexpw13,mexpw57,
     9           mexpw1,mexpw3,mexpw5,mexpw7,rdminus,
     9           xs,ys,zs,fexpback,rlsc,rscpow)
c--------------------------------------------------------------------
c      create up down expansions for box ibox
c-------------------------------------------------------------------
      implicit none
      integer nd
      integer ibox,ilev,nboxes,nterms,nlams,nthmax
      integer nphysical(nlams),nfourier(nlams)
      integer *8 iaddr(2,nboxes)
      integer ichild(8,nboxes)
      integer nexptot,nexptotp,nmax
      integer neall,nwall,ne1357,nw2468,ne13,ne57,nw24,nw68
      integer ne1,ne3,ne5,ne7,nw2,nw4,nw6,nw8
      integer eall(*),wall(*),e1357(*),w2468(*)
      integer e13(*),e57(*),w24(*),w68(*)
      integer e1(*),e3(*),e5(*),e7(*),w2(*),w4(*),w6(*),w8(*)
      double precision rscale
      double complex zk2
      double precision rlams(*),whts(*)
      double complex, allocatable :: tloc(:,:,:),tloc2(:,:,:)
      double complex mexp(nd,nexptotp,nboxes,6)
      double precision rdminus(0:nterms,0:nterms,-nterms:nterms)
      double precision rmlexp(*),centers(3,*)
      double complex mexpup(nd,nexptot),mexpdown(nexptot)
      double complex mexpupphys(nd,nexptotp),mexpdownphys(nd,nexptotp)
      double complex mexpeall(nd,nexptotp),mexpwall(nd,nexptotp)
      double complex mexpw1357(nd,nexptotp),mexpe2468(nd,nexptotp)
      double complex mexpw13(nd,nexptotp),mexpw57(nd,nexptotp)
      double complex mexpe24(nd,nexptotp),mexpe68(nd,nexptotp)
      double complex mexpw1(nd,nexptotp),mexpw3(nd,nexptotp)
      double complex mexpw5(nd,nexptotp),mexpw7(nd,nexptotp)
      double complex mexpe2(nd,nexptotp),mexpe4(nd,nexptotp)
      double complex mexpe6(nd,nexptotp),mexpe8(nd,nexptotp)
      double complex xs(-5:5,nexptotp),ys(-5:5,nexptotp)
      double precision zs(5,nexptotp)
      double precision rlsc(0:nterms,0:nterms,nlams),rscpow(0:nterms)
      double complex fexpback(*)

c      temp variables
      integer jbox,ctr,ii,jj,i,ix,iy,iz,j,l,idim
      double complex ztmp,zmul,ztmp2
      double precision rtmp,rtmp2
     
      double precision ctmp(3)

      allocate(tloc(nd,0:nterms,-nterms:nterms))
      allocate(tloc2(nd,0:nterms,-nterms:nterms))


      do i=1,nexptotp
        do idim=1,nd
          mexpeall(idim,i) = 0
          mexpwall(idim,i) = 0
          mexpe2468(idim,i) = 0
          mexpe24(idim,i) = 0
          mexpe68(idim,i) = 0
          mexpe2(idim,i) = 0
          mexpe4(idim,i) = 0
          mexpe6(idim,i) = 0
          mexpe8(idim,i) = 0
          mexpw1357(idim,i) = 0
          mexpw13(idim,i) = 0
          mexpw57(idim,i) = 0
          mexpw1(idim,i) = 0
          mexpw3(idim,i) = 0
          mexpw5(idim,i) = 0
          mexpw7(idim,i) = 0
        enddo
      enddo
      
   
      ctmp(1) = centers(1,ibox) - rscale/2.0d0
      ctmp(2) = centers(2,ibox) - rscale/2.0d0
      ctmp(3) = centers(3,ibox) - rscale/2.0d0
       
      do i=1,neall
        jbox = eall(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpwall(idim,j) = mexpwall(idim,j) + 
     1         mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne1357
        jbox = e1357(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw1357(idim,j) = mexpw1357(idim,j) + 
     1         mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne13
        jbox = e13(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw13(idim,j) = mexpw13(idim,j)+mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo


      do i=1,ne57
        jbox = e57(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw57(idim,j) = mexpw57(idim,j)+mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne1
        jbox = e1(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw1(idim,j) = mexpw1(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo


      do i=1,ne3
        jbox = e3(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
             mexpw3(idim,j) = mexpw3(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,ne5
        jbox = e5(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
             mexpw5(idim,j) = mexpw5(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo


      do i=1,ne7
        jbox = e7(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(ix,j)*xs(-iz,j)*ys(iy,j)
          do idim=1,nd
            mexpw7(idim,j) = mexpw7(idim,j) + mexp(idim,j,jbox,6)*zmul
          enddo
        enddo
      enddo

      do i=1,nwall
        jbox = wall(i)

        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale

         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpeall(idim,j) = mexpeall(idim,j) + 
     1         mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw2468
        jbox = w2468(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe2468(idim,j) = mexpe2468(idim,j) + 
     1          mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw24
        jbox = w24(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe24(idim,j) = mexpe24(idim,j)+mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

       

      do i=1,nw68
        jbox = w68(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe68(idim,j) = mexpe68(idim,j)+mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw2
        jbox = w2(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe2(idim,j) = mexpe2(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo


      do i=1,nw4
        jbox = w4(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe4(idim,j) = mexpe4(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw6
        jbox = w6(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe6(idim,j) = mexpe6(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

      do i=1,nw8
        jbox = w8(i)
        ix = 1.05d0*(centers(1,jbox)-ctmp(1))/rscale
        iy = 1.05d0*(centers(2,jbox)-ctmp(2))/rscale
        iz = 1.05d0*(centers(3,jbox)-ctmp(3))/rscale
         
        do j=1,nexptotp
          zmul = zs(-ix,j)*xs(iz,j)*ys(-iy,j)
          do idim=1,nd
            mexpe8(idim,j) = mexpe8(idim,j) + mexp(idim,j,jbox,5)*zmul
          enddo
        enddo
      enddo

c
cc       move contributions to the children
c


c      add contributions due to child 1
      jbox = ichild(1,ibox)

      if(jbox.gt.0) then
        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)
            mexpdownphys(idim,i) = mexpwall(idim,i)+mexpw1357(idim,i)+
     1         mexpw13(idim,i)+mexpw1(idim,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 2
      jbox = ichild(2,ibox)

      if(jbox.gt.0) then

        do i=1,nexptotp
          rtmp = 1/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1         mexpe24(idim,i)+mexpe2(idim,i))*zs(1,i)      
            mexpdownphys(idim,i) = mexpwall(idim,i)*rtmp
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)


        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)


        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif
  
c      add contributions due to child 3
      jbox = ichild(3,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)*ys(1,i)
            mexpdownphys(idim,i) = (mexpwall(idim,i)+mexpw1357(idim,i)+
     1         mexpw13(idim,i)+mexpw3(idim,i))*ys(-1,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 4
      jbox = ichild(4,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = zs(1,i)*ys(1,i)
          ztmp2 = ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1         mexpe24(idim,i)+mexpe4(idim,i))*ztmp      
            mexpdownphys(idim,i) = mexpwall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 5
      jbox = ichild(5,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)*xs(-1,i)
            mexpdownphys(idim,i) = (mexpwall(idim,i)+mexpw1357(idim,i)+
     1             mexpw57(idim,i)+mexpw5(idim,i))*xs(1,i)
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 6
      jbox = ichild(6,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(-1,i)*zs(1,i)
          ztmp2 = xs(1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1           mexpe68(idim,i)+mexpe6(idim,i))*ztmp      
            mexpdownphys(idim,i) = mexpwall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)
      endif

c      add contributions due to child 7
 
      jbox = ichild(7,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(-1,i)*ys(1,i)
          ztmp2 = xs(1,i)*ys(-1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = mexpeall(idim,i)*ztmp
            mexpdownphys(idim,i) = (mexpwall(idim,i)+mexpw1357(idim,i)+
     1          mexpw57(idim,i)+mexpw7(idim,i))*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

c      add contributions due to child 8
      jbox = ichild(8,ibox)
      if(jbox.gt.0) then

        do i=1,nexptotp
          ztmp = xs(-1,i)*ys(1,i)*zs(1,i)
          ztmp2 = xs(1,i)*ys(-1,i)/zs(1,i)
          do idim=1,nd
            mexpupphys(idim,i)  = (mexpeall(idim,i)+mexpe2468(idim,i)+
     1         mexpe68(idim,i)+mexpe8(idim,i))*ztmp      
            mexpdownphys(idim,i) = mexpwall(idim,i)*ztmp2
          enddo
        enddo

        call phystof(nd,mexpup,nlams,nfourier,nphysical,
     1               mexpupphys,fexpback)
 
        call phystof(nd,mexpdown,nlams,nfourier,nphysical,
     1              mexpdownphys,fexpback)

        call exptolocal(nd,tloc,nterms,rlams,whts,
     1         nlams,nfourier,nthmax,nexptot,mexpup,mexpdown,
     2         rscale,rlsc)

        call rotztox(nd,nterms,tloc,tloc2,rdminus)

        call mpscale(nd,nterms,tloc2,rscpow,tloc2)
        call mpadd(nd,tloc2,rmlexp(iaddr(2,jbox)),nterms)

      endif

      return
      end
c--------------------------------------------------------------------      
