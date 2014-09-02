
#include <QApplication>

#include "grid/wgrid.h"
#include "grid/qgrid.h"

// ---------------------------------------------------------------------
void WGrid::draw()
{
  int w,h;
  int maxinit=5000;

  if (!drawinit()) return;

  w=getcellcount(sa->width()-Lw,Scls,Cws);
  h=getcellcount(sa->height()-Hh,Srws,Chs);

  if (!WGridInit) {
    if (maxinit < Crws*Ccls) {
      h=qMax(h,qMin(Crws,maxinit/w));
      w=qMax(w,qMin(Ccls,maxinit/h));
    } else {
      w=Ccls;
      h=Crws;
    }
    WGridInit=true;
  }

//timex("");
  drawsizes(Scls,Srws,w,h);
//timex("draw sizes");
  drawview();
  drawpixmaps();
  drawtop();
  drawheaders();
  drawlabels();
  drawcells();
}

// ---------------------------------------------------------------------
bool WGrid::drawinit()
{
  if (WGridInit) return true;

  if (sa->style=="cube") {
    sa->p->drawcube();
  }

  if (!validmerge(Ccls,HdrMerge))
    return griderror("Header merge will wrap around");

  if (!validmerge(Crws,LabMerge))
    return griderror("Label merge will wrap around");

  if (0 != HdrX.size() % Ccls)
    return griderror("Header length of " + QString::number(HdrX.size())  +
                     " does not match data columns of " + QString::number(Ccls) );

  if (0 != LabX.size() % Crws)
    return griderror("Label length of " + QString::number(LabX.size())
                     + " does not match data rows of " + QString::number(Crws) );

  QFontMetrics fm=QFontMetrics(font);
  minwidth=fm.width("XXX");
  minheight=fm.height();

  int n;
  n=Data.size();
  Dws.fill(minwidth,n);
  Dhs.fill(minheight,n);
  Dfm.fill(false,n);

  n=HdrX.size();
  Hrws=n/Ccls;
  Hh=minheight*Hrws;
  Hws.fill(minwidth,n);
  Hhs.fill(minheight,n);
  Hhx.fill(minheight,Hrws);
  Hfm.fill(false,n);

  n=LabX.size();
  Lcls=n/Crws;
  Lw=minwidth*Lcls;
  Lws.fill(minwidth,n);
  Lhs.fill(minheight,n);
  Lwx.fill(minwidth,Lcls);
  Lfm.fill(false,n);

  Twx.fill(minwidth,Ccls);
  Thx.fill(minheight,Crws);
  Cws=Twx;
  Chs=Thx;

  HdrMergeIndex=hdrmergeindex(HdrMerge);
  LabMergeIndex=hdrmergeindex(LabMerge);
  HdrMergeMask=hdrmergemask(HdrMerge);
  LabMergeMask=hdrmergemask(LabMerge);
  hdrmergesizes();
  labmergesizes();

  return true;
}

// ---------------------------------------------------------------------
void WGrid::drawpixmaps()
{
  delete pmall;
  delete pmtop;
  delete pmhdr;
  delete pmlab;
  delete pmcell;

  pmall=new QPixmap(Lw+Vw+1,Hh+Vh+1);
  pmtop=new QPixmap(Lw+1,Hh+1);
  pmhdr=new QPixmap(Vw+1,Hh+1);
  pmlab=new QPixmap(Lw+1,Vh+1);
  pmcell=new QPixmap(Vw+1,Vh+1);

  pmall->fill(QApplication::palette().window().color());
}

// ---------------------------------------------------------------------
void WGrid::drawview()
{
  resize(Gw+1,Gh+1);
  sa->setscroll();
  Vcls=viewlength(Cws,Scls,sa->width()-Lw);
  Vrws=viewlength(Chs,Srws,sa->height()-Hh);
  Vws=Cws.mid(Scls,Vcls);
  Vhs=Chs.mid(Srws,Vrws);
  Vwp=vsumscanp(0,Vws);
  Vhp=vsumscanp(0,Vhs);
  Vw=Vwp.last();
  Vh=Vhp.last();
}

// ---------------------------------------------------------------------
void WGrid::hdrmergesizes()
{
  HdrMergeSizes.clear();
  if (HdrMerge==DefMerge) return;

  int c,i,n;
  QFontMetrics fm=QFontMetrics(font);
  QVector<int> r(3);

  for (i=0; i<HdrMerge.size(); i++) {
    if (HdrMerge[i]==1) continue;
    n=HdrMerge[i];
    c=HdrMergeIndex[i]%Ccls;
    r[0]=c;
    r[1]=c+n-1;
    r[2]=fm.width(Hdr[n]);
    HdrMergeSizes.append(r);
  }
}

// ---------------------------------------------------------------------
void WGrid::labmergesizes()
{
  LabMergeSizes.clear();
  if (LabMerge==DefMerge) return;

  int c,i,n;
  QFontMetrics fm=QFontMetrics(font);
  QVector<int> r(3);

  for (i=0; i<LabMerge.size(); i++) {
    if (LabMerge[i]==1) continue;
    n=LabMerge[i];
    c=LabMergeIndex[i]%Crws;
    r[0]=c;
    r[1]=c+n-1;
    r[2]=fm.height();
    LabMergeSizes.append(r);
  }
}

