program test_hfmm3d_mp2loc
  implicit double precision (a-h,o-z)
  
  character(len=72) str1
  
  integer :: ns, nt, nc
  integer :: i,j,k,ntest,nd,idim
  integer :: ifcharge,ifdipole,ifpgh,ifpghtarg
  integer :: ipass(18),len1,ntests,isum
  
  double precision :: eps, err, hkrand, dnorms(1000), force(10)
  double precision, allocatable :: source(:,:), targ(:,:)
  double precision, allocatable :: centers(:,:)
  double precision, allocatable :: wlege(:)
  
  double complex :: eye, zk, ima
  double complex, allocatable :: charge(:,:)
  double complex, allocatable :: dipvec(:,:,:)
  double complex, allocatable :: pot(:,:), pot2(:,:), pottarg(:,:)
  double complex, allocatable :: grad(:,:,:),gradtarg(:,:,:)
  double complex, allocatable :: mpole(:,:,:,:), local(:,:,:,:)


  data eye/(0.0d0,1.0d0)/
  ima = (0,1)
  done = 1
  pi = 4*atan(done)

  !
  ! initialize printing routine
  !
  call prini(6,13)

  nd = 3

  dlam = .5d0
  zk = 2*pi/dlam + eye*0.02d0

  ns = 1000
  nc = ns
  nt = 19

  ntest = 10

  allocate(source(3,ns),targ(3,nt), centers(3,nc))
  allocate(charge(nd,ns),dipvec(nd,3,ns))
  allocate(pot(nd,ns), pot2(nd,ns))
  allocate(grad(nd,3,ns))

  allocate(pottarg(nd,nt))
  allocate(gradtarg(nd,3,nt))
  eps = 0.5d-9

  write(*,*) "=========================================="
  write(*,*) "Testing suite for hfmm3d_mps"
  write(*,'(a,e11.5)') "Requested precision = ",eps

  open(unit=33,file='print_testres.txt',access='append')

  ntests = 18
  do i=1,ntests
    ipass(i) = 0
  enddo

  !
  ! generate sources uniformly in the unit cube 
  !
  dnorm = 0
  do i=1,ns
    source(1,i) = hkrand(0)**2
    source(2,i) = hkrand(0)**2
    source(3,i) = hkrand(0)**2

    do idim=1,nd

      charge(idim,i) = hkrand(0) + eye*hkrand(0)
      dnorm = dnorm + abs(charge(idim,i))**2
      
      dipvec(idim,1,i) = hkrand(0) + eye*hkrand(0)
      dipvec(idim,2,i) = hkrand(0) + eye*hkrand(0)
      dipvec(idim,3,i) = hkrand(0) + eye*hkrand(0)

      pot(idim,i) = 0
      grad(idim,1,i) = 0
      grad(idim,2,i) = 0
      grad(idim,3,i) = 0
    enddo
  enddo

  dnorm = sqrt(dnorm)
  do i=1,ns
    do idim = 1,nd
      charge(idim,i) = charge(idim,i)/dnorm
    end do
  end do
  
  
  ! !
  ! ! spread out the sources a little bit
  ! !
  ! do l = 1,0
  !   do i = 1,ns
  !     force(1) = 0
  !     force(2) = 0
  !     force(3) = 0
  !     do j = 1,ns
  !       if (i .ne. j) then
  !         rs = 0
  !         do k = 1,3
  !           rs = rs + (source(k,i)-source(k,j))**2
  !         end do
  !         rs = sqrt(rs)
  !         force(1) = (source(1,i)-source(1,j))/rs**3
  !         force(1) = (source(2,i)-source(2,j))/rs**3
  !         force(1) = (source(3,i)-source(3,j))/rs**3
  !         alpha = -1d0
  !         source(1,i) = source(1,i) + alpha*force(1)
  !         source(2,i) = source(2,i) + alpha*force(2)
  !         source(3,i) = source(3,i) + alpha*force(3)
  !       end if
  !     end do
  !   end do
  ! end do
  
  
  


  ! !
  ! ! generate targets uniformly in the unit cube
  ! !
  ! do i=1,nt
  !   targ(1,i) = hkrand(0)
  !   targ(2,i) = hkrand(0)
  !   targ(3,i) = hkrand(0)

  !   do idim=1,nd

  !     pottarg(idim,i) = 0
  !     gradtarg(idim,1,i) = 0
  !     gradtarg(idim,2,i) = 0
  !     gradtarg(idim,3,i) = 0 
  !   enddo
  ! enddo


  !
  ! calculate min source separation and min
  ! target separation
  !
  ssep = 1000
  do i = 1,ns
    do j = 1,ns
      if (i .ne. j) then
        rs = 0
        do k = 1,3
          rs = rs + (source(k,i)-source(k,j))**2
        end do
        rs = sqrt(rs)
        if (rs .lt. ssep) ssep = rs
      end if

    end do
  end do

  call prin2('min source separation = *', ssep, 1)
  
  shift = ssep/10
  do i = 1,ns
    centers(1,i) = source(1,i) + shift
    centers(2,i) = source(2,i)
    centers(3,i) = source(3,i)
  end do

  !call prin2('centers = *', centers, 3*nc)

  !
  ! now form a multipole expansion at each center
  !
  nterms = 15
  allocate( mpole(nd,0:nterms,-nterms:nterms,nc) )
 
  nlege = nterms + 10
  lw = 4*(nlege+1)**2
  allocate( wlege(lw) )

  call prinf('before ylgndrfwini, lw = *', lw, 1)
  call ylgndrfwini(nlege, wlege, lw, lused)
  call prinf('after ylgndrfwini, lused = *', lused, 1)

  len = nd*(nterms+1)*(2*nterms+1)*nc
  call zinitialize(len, mpole)
  
  ns1 = 1
  sc = abs(zk)*shift
  if (sc .lt. 1) rscale = sc
  do i = 1,nc
    call h3dformmpc(nd, zk, rscale, source(1,i), charge(1,i), &
        ns1, centers(1,i), nterms, mpole(:,:,:,i), wlege, nlege)
  end do

  !
  ! do the direct calculation
  !
  thresh = 1.0d-15
  call h3ddirectcp(nd, zk, source, charge, ns, source, ns, &
      pot, thresh)

  call prin2('directly, potential = *', pot, 10)

  !
  ! now evaluate all the multipoles and compare
  !
  do i = 1,ns

    do idim = 1,nd
      pot2(idim,i) = 0
    end do
    
    do j = 1,ns
      if (i .ne. j) then
        call h3dmpevalp(nd, zk, rscale, centers(1,j), mpole(:,:,:,j), &
            nterms, source(1,i), ns1, pot2(1,i), wlege, nlege, thresh)
      end if
    end do
  end do

  call prin2('from mpeval, potential2 = *', pot2, 10)

  do i = 1,nd
    dnorms(i) = 0
  end do

  do i = 1,ns
    do idim = 1,nd
      dnorms(idim) = dnorms(idim) + abs(pot(idim,i)-pot2(idim,i))**2
      pot2(idim,i) = pot(idim,i) - pot2(idim,i)
    end do
  end do

  do i = 1,nd
    dnorms(i) = sqrt(dnorms(i))
  end do

  call prin2('diffs in potentials = *', pot2, 10)  
  call prin2('l2 error in potentials = *', dnorms, nd)
  
  !
  ! now try the fmps routine
  !
  !write(6,*) 'testing fast multi-particle scattering'
  !write(6,*) 'input: multipoles'
  !write(6,*) 'output: local expansions'

  
  !allocate( local(nd,0:nterms,-nterms:nterms,nc) )
  !call hfmm3d_mps_vec(nd, eps, zk, nc, centers, rscales, nterms, &
  !    mpole, local)

  



  

  !
  ! now test source to source, charge, 
  ! with potentials
  !
  write(6,*) 'testing source to source'
  write(6,*) 'interaction: charges'
  write(6,*) 'output: potentials'
  write(6,*) 
  write(6,*) 

  call zinitialize(nd*ns, pot)
  
  call hfmm3d_s_c_p_vec(nd,eps,zk,ns,source,charge, &
      pot)

  ifcharge = 1
  ifdipole = 0
  ifpgh = 1
  ifpghtarg = 0


  call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,&
      dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg, &
      ntest,err)

  call prin2('l2 rel err=*',err,1)
  write(6,*)
  write(6,*)
  write(6,*) '================'
  if(err.lt.eps) ipass(1) = 1
  call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  if(err.ge.eps) write(33,*) str1(1:len1) 



  ! c

  ! c
  ! cc     now test source to source, charge, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to source'
  !        write(6,*) 'interaction: charges'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_s_c_g_vec(nd,eps,zk,ns,source,charge,
  !      1      pot,grad)

  !        ifcharge = 1
  !        ifdipole = 0
  !        ifpgh = 2
  !        ifpghtarg = 0


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(2) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 



  ! c
  ! cc     now test source to source, dipole, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to source'
  !        write(6,*) 'interaction: dipoles'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_s_d_p_vec(nd,eps,zk,ns,source,dipvec,
  !      1      pot)

  !        ifcharge = 0
  !        ifdipole = 1
  !        ifpgh = 1
  !        ifpghtarg = 0


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(3) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to source, dipole, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to source'
  !        write(6,*) 'interaction: dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_s_d_g_vec(nd,eps,zk,ns,source,dipvec,
  !      1      pot,grad)

  !        ifcharge = 0
  !        ifdipole = 1
  !        ifpgh = 2
  !        ifpghtarg = 0


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(4) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 

  ! c
  ! cc     now test source to source, charge + dipole, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to source'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_s_cd_p_vec(nd,eps,zk,ns,source,charge,
  !      1      dipvec,pot)

  !        ifcharge = 1
  !        ifdipole = 1
  !        ifpgh = 1
  !        ifpghtarg = 0 


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(5) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to source, charge + dipole, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to source'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_s_cd_g_vec(nd,eps,zk,ns,source,charge,
  !      1      dipvec,pot,grad)

  !        ifcharge = 1
  !        ifdipole = 1
  !        ifpgh = 2
  !        ifpghtarg = 0


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(6) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 



  ! c
  ! cc     now test source to target, charge, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to target'
  !        write(6,*) 'interaction: charges'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_t_c_p_vec(nd,eps,zk,ns,source,charge,
  !      1      nt,targ,pottarg)

  !        ifcharge = 1
  !        ifdipole = 0
  !        ifpgh = 0
  !        ifpghtarg = 1


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(7) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to target, charge, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to target'
  !        write(6,*) 'interaction: charges'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_t_c_g_vec(nd,eps,zk,ns,source,charge,
  !      1      nt,targ,pottarg,gradtarg)

  !        ifcharge = 1
  !        ifdipole = 0
  !        ifpgh = 0
  !        ifpghtarg = 2


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(8) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 



  ! c
  ! cc     now test source to target, dipole, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to target'
  !        write(6,*) 'interaction: dipoles'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_t_d_p_vec(nd,eps,zk,ns,source,dipvec,
  !      1      nt,targ,pottarg)

  !        ifcharge = 0
  !        ifdipole = 1
  !        ifpgh = 0
  !        ifpghtarg = 1


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(9) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to target, dipole, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to target'
  !        write(6,*) 'interaction: dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_t_d_g_vec(nd,eps,zk,ns,source,dipvec,
  !      1      nt,targ,pottarg,gradtarg)

  !        ifcharge = 0
  !        ifdipole = 1
  !        ifpgh = 0
  !        ifpghtarg = 2


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(10) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 

  ! c
  ! cc     now test source to target, charge + dipole, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to target'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_t_cd_p_vec(nd,eps,zk,ns,source,charge,
  !      1      dipvec,nt,targ,pottarg)

  !        ifcharge = 1
  !        ifdipole = 1
  !        ifpgh = 0
  !        ifpghtarg = 1


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(11) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to target, charge + dipole, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to target'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_t_cd_g_vec(nd,eps,zk,ns,source,charge,
  !      1      dipvec,nt,targ,pottarg,gradtarg)

  !        ifcharge = 1
  !        ifdipole = 1
  !        ifpgh = 0
  !        ifpghtarg = 2


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(12) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 

  ! c
  ! cc     now test source to source + target, charge, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to source and target'
  !        write(6,*) 'interaction: charges'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_st_c_p_vec(nd,eps,zk,ns,source,charge,
  !      1      pot,nt,targ,pottarg)

  !        ifcharge = 1
  !        ifdipole = 0
  !        ifpgh = 1
  !        ifpghtarg = 1


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(13) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to source + target, charge, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to source and target'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_st_c_g_vec(nd,eps,zk,ns,source,charge,
  !      1      pot,grad,nt,targ,pottarg,gradtarg)

  !        ifcharge = 1
  !        ifdipole = 0
  !        ifpgh = 2
  !        ifpghtarg = 2


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(14) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 



  ! c
  ! cc     now test source to source + target, dipole, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to source and target'
  !        write(6,*) 'interaction: dipoles'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_st_d_p_vec(nd,eps,zk,ns,source,dipvec,
  !      1      pot,nt,targ,pottarg)

  !        ifcharge = 0
  !        ifdipole = 1
  !        ifpgh = 1
  !        ifpghtarg = 1


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(15) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to source + target, dipole, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to source and target'
  !        write(6,*) 'interaction: dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_st_d_g_vec(nd,eps,zk,ns,source,dipvec,
  !      1      pot,grad,nt,targ,pottarg,gradtarg)

  !        ifcharge = 0
  !        ifdipole = 1
  !        ifpgh = 2
  !        ifpghtarg = 2


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(16) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 

  ! c
  ! cc     now test source to source + target, charge + dipole, 
  ! c      with potentials
  ! c
  !        write(6,*) 'testing source to source and target'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_st_cd_p_vec(nd,eps,zk,ns,source,charge,
  !      1      dipvec,pot,nt,targ,pottarg)

  !        ifcharge = 1
  !        ifdipole = 1
  !        ifpgh = 1
  !        ifpghtarg = 1


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(17) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  ! c
  ! cc     now test source to source + target, charge + dipole, 
  ! c      with potentials and gradients
  ! c
  !        write(6,*) 'testing source to source and target'
  !        write(6,*) 'interaction: charges + dipoles'
  !        write(6,*) 'output: potentials + gradients'
  !        write(6,*) 
  !        write(6,*) 

  !        call hfmm3d_st_cd_g_vec(nd,eps,zk,ns,source,charge,
  !      1      dipvec,pot,grad,nt,targ,pottarg,gradtarg)

  !        ifcharge = 1
  !        ifdipole = 1
  !        ifpgh = 2
  !        ifpghtarg = 2


  !        call comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole,
  !      1   dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg,gradtarg,
  !      2   ntest,err)

  !        call prin2('l2 rel err=*',err,1)
  !        write(6,*)
  !        write(6,*)
  !        write(6,*) '================'
  !       if(err.lt.eps) ipass(18) = 1
  !       call geterrstr(ifcharge,ifdipole,ifpgh,ifpghtarg,str1,len1)
  !       if(err.ge.eps) write(33,*) str1(1:len1) 


  !       isum = 0
  !       do i=1,ntests
  !         isum = isum+ipass(i)
  !       enddo

  !       write(*,'(a,i2,a,i2,a)') 'Successfully completed ',isum,
  !      1   ' out of ',ntests,' tests in hfmm3d vec testing suite'
  !       write(33,'(a,i2,a,i2,a)') 'Successfully completed ',isum,
  !      1   ' out of ',ntests,' tests in hfmm3d vec testing suite'
  !       close(33)


  stop
end program

! ----------------------------------------------------------
! 
! This is the end of the debugging code.
!
! ----------------------------------------------------------



subroutine zinitialize(len, zs)
  implicit double precision (a-h,o-z)
  double complex :: zs(len)

  do i = 1,len
    zs(i) = 0
  end do
  return
end subroutine zinitialize





subroutine comperr_vec(nd,zk,ns,source,ifcharge,charge,ifdipole, &
    dipvec,ifpgh,pot,grad,nt,targ,ifpghtarg,pottarg, &
    gradtarg,ntest,err)

  implicit none
  double complex zk
  integer ns,nt,ifcharge,ifdipole,ifpgh,ifpghtarg

  double precision source(3,*),targ(3,*)
  double complex dipvec(nd,3,*)
  double complex charge(nd,*)

  double complex pot(nd,*),pottarg(nd,*),grad(nd,3,*), &
      gradtarg(nd,3,*)

  integer i,j,ntest,nd,idim

  double precision err,ra

  double complex potex(nd,ntest),gradex(nd,3,ntest), &
      pottargex(nd,ntest),gradtargex(nd,3,ntest)

  double precision thresh

  err = 0 
  do i=1,ntest
    do idim=1,nd
      potex(idim,i) = 0
      pottargex(idim,i) = 0

      gradex(idim,1,i) = 0
      gradex(idim,2,i) = 0
      gradex(idim,3,i) = 0

      gradtargex(idim,1,i) = 0
      gradtargex(idim,2,i) = 0
      gradtargex(idim,3,i) = 0
    enddo
  enddo

  thresh = 1.0d-16

  if(ifcharge.eq.1.and.ifdipole.eq.0) then
    if(ifpgh.eq.1) then
      call h3ddirectcp(nd,zk,source,charge,ns,source,ntest, &
          potex,thresh)
    endif

    if(ifpgh.eq.2) then
      call h3ddirectcg(nd,zk,source,charge,ns,source,ntest, &
          potex,gradex,thresh)
    endif

    if(ifpghtarg.eq.1) then
      call h3ddirectcp(nd,zk,source,charge,ns,targ,ntest, &
          pottargex,thresh)
    endif

    if(ifpghtarg.eq.2) then
      call h3ddirectcg(nd,zk,source,charge,ns,targ,ntest, &
          pottargex,gradtargex,thresh)
    endif
  endif

  if(ifcharge.eq.0.and.ifdipole.eq.1) then
    if(ifpgh.eq.1) then
      call h3ddirectdp(nd,zk,source,dipvec, &
          ns,source,ntest,potex,thresh)
    endif

    if(ifpgh.eq.2) then
      call h3ddirectdg(nd,zk,source,dipvec, &
          ns,source,ntest,potex,gradex,thresh)
    endif

    if(ifpghtarg.eq.1) then
      call h3ddirectdp(nd,zk,source,dipvec, &
          ns,targ,ntest,pottargex,thresh)
    endif

    if(ifpghtarg.eq.2) then
      call h3ddirectdg(nd,zk,source,dipvec, &
          ns,targ,ntest,pottargex,gradtargex,thresh)
    endif
  endif

  if(ifcharge.eq.1.and.ifdipole.eq.1) then
    if(ifpgh.eq.1) then
      call h3ddirectcdp(nd,zk,source,charge,dipvec, &
          ns,source,ntest,potex,thresh)
    endif

    if(ifpgh.eq.2) then
      call h3ddirectcdg(nd,zk,source,charge,dipvec, &
          ns,source,ntest,potex,gradex,thresh)
    endif

    if(ifpghtarg.eq.1) then
      call h3ddirectcdp(nd,zk,source,charge,dipvec, &
          ns,targ,ntest,pottargex,thresh)
    endif

    if(ifpghtarg.eq.2) then
      call h3ddirectcdg(nd,zk,source,charge,dipvec, &
          ns,targ,ntest,pottargex,gradtargex,thresh)
    endif
  endif

  err = 0
  ra = 0

  if(ifpgh.eq.1) then
    do i=1,ntest
      do idim=1,nd
        ra = ra + abs(potex(idim,i))**2
        err = err + abs(pot(idim,i)-potex(idim,i))**2
      enddo
    enddo
  endif

  if(ifpgh.eq.2) then
    do i=1,ntest
      do idim=1,nd
        ra = ra + abs(potex(idim,i))**2
        ra = ra + abs(gradex(idim,1,i))**2
        ra = ra + abs(gradex(idim,2,i))**2
        ra = ra + abs(gradex(idim,3,i))**2

        err = err + abs(pot(idim,i)-potex(idim,i))**2
        err = err + abs(grad(idim,1,i)-gradex(idim,1,i))**2
        err = err + abs(grad(idim,2,i)-gradex(idim,2,i))**2
        err = err + abs(grad(idim,3,i)-gradex(idim,3,i))**2
      enddo
    enddo
  endif


  if(ifpghtarg.eq.1) then
    do i=1,ntest
      do idim=1,nd
        ra = ra + abs(pottargex(idim,i))**2
        err = err + abs(pottarg(idim,i)-pottargex(idim,i))**2
      enddo
    enddo
  endif

  if(ifpghtarg.eq.2) then
    do i=1,ntest
      do idim=1,nd
        ra = ra + abs(pottargex(idim,i))**2
        ra = ra + abs(gradtargex(idim,1,i))**2
        ra = ra + abs(gradtargex(idim,2,i))**2
        ra = ra + abs(gradtargex(idim,3,i))**2

        err = err + abs(pottarg(idim,i)-pottargex(idim,i))**2
        err = err + abs(gradtarg(idim,1,i)-gradtargex(idim,1,i))**2
        err = err + abs(gradtarg(idim,2,i)-gradtargex(idim,2,i))**2
        err = err + abs(gradtarg(idim,3,i)-gradtargex(idim,3,i))**2
      enddo
    enddo
  endif

  err = sqrt(err/ra)
  return
end subroutine comperr_vec
