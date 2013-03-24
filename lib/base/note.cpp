#include <QAction>
#include <QApplication>
#include <QBoxLayout>
#include <QDesktopWidget>

#include "base.h"
#include "nedit.h"
#include "note.h"
#include "nmain.h"
#include "nside.h"
#include "ntabs.h"
#include "menu.h"
#include "proj.h"
#include "psel.h"
#include "svr.h"
#include "recent.h"
#include "state.h"
#include "term.h"
#include "tedit.h"

using namespace std;

Note *note=0;
Note *note2=0;

// ---------------------------------------------------------------------
Note::Note()
{
  setFocusPolicy(Qt::StrongFocus);
  sideBarShow=true;
  QVBoxLayout *layout=new QVBoxLayout;
  layout->setContentsMargins(layout->contentsMargins());
  layout->setSpacing(0);
  menuBar = new Menu();
  split = new QSplitter(0);
  sideBar = new Nside();
  mainBar = new Nmain(this);
  split->addWidget(sideBar);
  split->addWidget(mainBar);
  split->setStretchFactor(1,1);
  QList<int> w;
  w << 175 << 175;
  split->setSizes(w);
  layout->addWidget(menuBar);
  layout->addWidget(split);
  layout->setStretchFactor(split,1);
  setLayout(layout);
  setWindowTitle("[*]edit");
  setpos();
  menuBar->createActions();
  menuBar->createMenus("note");
  menuBar->createMenus_fini("note");
  QString s=config.SystemPath.filePath("bin/icons/jgreen.png");
  setWindowIcon(QIcon(s));
  QMetaObject::connectSlotsByName(this);
}

// ---------------------------------------------------------------------
void Note::activate()
{
  activateWindow();
  int n=editIndex();
  if (n>=0)
    tabs->currentWidget()->setFocus();
}

// ---------------------------------------------------------------------
void Note::changeEvent(QEvent *event)
{
  if (NoEvents) return;
  if (event->type()==QEvent::ActivationChange && isActiveWindow())  {
    setnote(this);
    projectenable();
    QWidget::changeEvent(event);
  }
}

// ---------------------------------------------------------------------
void Note::closeEvent(QCloseEvent *event)
{
  Q_UNUSED(event);
  closeit();
}

// ---------------------------------------------------------------------
void Note::closeit()
{
  projectsave();
  if (note2) {
    note=note2;
    note2=0;
    note->setFocus();
  } else
    note=0;
  close();
}

// ---------------------------------------------------------------------
int Note::editIndex()
{
  return tabs->currentIndex();
}

// ---------------------------------------------------------------------
QString Note::editFile()
{
  if (tabs->count()==0) return "";
  return ((Nedit *)tabs->currentWidget())->fname;
}

// ---------------------------------------------------------------------
Nedit *Note::editPage()
{
  return (Nedit *) tabs->currentWidget();
}

// ---------------------------------------------------------------------
QString Note::editText()
{
  return ((Nedit *)tabs->currentWidget())->toPlainText();
}

// ---------------------------------------------------------------------
// close tab with file
void Note::fileclose(QString f)
{
  tabs->tabclosefile(f);
}

// ---------------------------------------------------------------------
bool Note::fileopen(QString s,int line)
{
  return tabs->tabopen(s,line);
}

// ---------------------------------------------------------------------
void Note::keyPressEvent(QKeyEvent *event)
{
  switch (event->key()) {
  case Qt::Key_Escape:
    closeit();
  default:
    QWidget::keyPressEvent(event);
  }
}

// ---------------------------------------------------------------------
void Note::loadscript(QString s,bool show)
{
  if (note->saveall())
    tedit->loadscript(s,show);
}

// ---------------------------------------------------------------------
void Note::newtemp()
{
  QString f=newtempscript();
  cfcreate(f);
  openfile1(f);
}

// ---------------------------------------------------------------------
void Note::on_lastprojectAct_triggered()
{
  projectsave();
  project.open(project.LastId);
  projectopen(true);
}

// ---------------------------------------------------------------------
void Note::on_openprojectAct_triggered()
{
  new Psel();
}

// ---------------------------------------------------------------------
void Note::on_runallAct_triggered()
{
  runlines(true);
}

// ---------------------------------------------------------------------
void Note::prettyprint()
{
  int n,pos,top;
  QString r;
  savecurrent();
  Nedit *e=editPage();
  var_cmd("require PPScript_jp_");
  var_set("arg_jpp_",editText());
  r=var_cmdr("pplintqt_jpp_ arg_jpp_");
  if (r.isEmpty()) return;
  if (r.at(0)=='0') {
    pos=e->readcurpos();
    top=e->readtop();
    r.remove(0,1);
    settext(r);
    e->settop(top);
    e->setcurpos(pos);
  } else {
    r.remove(0,1);
    n=r.indexOf(' ');
    selectline(r.mid(0,n).toInt());
    info ("Format Script",r.mid(n+1));
  }
}

// ---------------------------------------------------------------------
void Note::projectenable()
{
  bool b=project.Id.size()>0;
  foreach(QAction *s, menuBar->ProjectEnable)
  s->setEnabled(b);
}

// ---------------------------------------------------------------------
void Note::projectopen(bool b)
{
  tabs->projectopen(b);
  scriptenable();
  projectenable();
}

// ---------------------------------------------------------------------
void Note::projectsave()
{
  if (tabs->Id.size())
    project.save(tabs->gettablist());
}

// ---------------------------------------------------------------------
bool Note::saveall()
{
  return tabs->tabsaveall();
}

// ---------------------------------------------------------------------
void Note::savecurrent()
{
  tabs->tabsave(editIndex());
}

// ---------------------------------------------------------------------
void Note::scriptenable()
{
  bool b=tabs->count();
  menuBar->selMenu->setEnabled(b);
  foreach(QAction *s, menuBar->ScriptEnable)
  s->setEnabled(b);

}

// ---------------------------------------------------------------------
void Note::selectline(int linenum)
{
  editPage()->selectline(linenum);
}

// ---------------------------------------------------------------------
void Note::select_line(QString s)
{
  int pos,len;
  QString com,hdr,ftr,txt;
  QStringList mid;
  Nedit *e=editPage();
  config.filepos_set(e->fname,e->readtop());
  txt=e->readselect_line(&pos,&len);
  hdr=txt.mid(0,pos);
  mid=txt.mid(pos,len).split('\n');
  ftr=txt.mid(pos+len);
  mid=select_line1(mid,s,&pos,&len);
  e->setPlainText(hdr+mid.join("\n")+ftr);
  e->settop(config.filepos_get(e->fname));
  e->setselect(pos,len);
  siderefresh();
}

// ---------------------------------------------------------------------
QStringList Note::select_line1(QStringList mid,QString s,int *pos, int *len)
{
  int i;
  QString com, comment, p, t;

  if (s=="sort") {
    mid.sort();
    return mid;
  }

  if (s=="wrap") {
    return mid;
  }

  comment=editPage()->getcomment();
  if (comment.isEmpty()) return mid;
  com=comment+" ";

  if (s=="minus") {
    for(i=0; i<mid.size(); i++) {
      p=mid.at(i);
      if (matchhead(comment,p) && (!matchhead(com+"----",p))
          && (!matchhead(com+"====",p)))
        p=p.mid(comment.size());
      if (p.size() && (p.at(0)==' '))
        p=p.mid(1);
      mid.replace(i,p);
    }
    *len=mid.join("a").size();
    return mid;
  }

  if (s=="plus") {
    for(i=0; i<mid.size(); i++) {
      p=mid.at(i);
      if (p.size())
        p=com+p;
      else
        p=comment;
      mid.replace(i,p);
    }
    *len=mid.join("a").size();
    return mid;
  }

  if (s=="plusline1")
    t.fill('-',57);
  else
    t.fill('=',57);

  t=com + t;
  mid.prepend(t);
  *pos=*pos+1+t.size();
  *len=0;
  return mid;
}

// ---------------------------------------------------------------------
void Note::select_text(QString s)
{
  int i,pos,len;
  QString hdr,mid,ftr,txt;
  Nedit *e=editPage();
  config.filepos_set(e->fname,e->readtop());
  txt=e->readselect_text(&pos,&len);
  if (len==0) {
    info("Note","No text selected") ;
    return;
  }

  hdr=txt.mid(0,pos);
  mid=txt.mid(pos,len);
  ftr=txt.mid(pos+len);

  if (s=="lower")
    mid=mid.toLower();
  else if (s=="upper")
    mid=mid.toUpper();
  else if (s=="toggle") {
    QString old=mid;
    QString lc=mid.toLower();
    mid=mid.toUpper();
    for (i=0; i<mid.size(); i++)
      if(mid[i]==old[i]) mid[i]=lc[i];
  }
  e->setPlainText(hdr+mid+ftr);
  e->settop(config.filepos_get(e->fname));
  e->setselect(pos,0);
  siderefresh();
}

// ---------------------------------------------------------------------
void Note::setfont(QFont font)
{
  tabs->setfont(font);
}

// ---------------------------------------------------------------------
void Note::setindex(int index)
{
  tabs->tabsetindex(index);
}

// ---------------------------------------------------------------------
void Note::setlinenos(bool b)
{
  menuBar->viewlinenosAct->setChecked(b);
  tabs->setlinenos(b);
}

// ---------------------------------------------------------------------
void Note::setlinewrap(bool b)
{
  menuBar->viewlinewrapAct->setChecked(b);
  tabs->setlinewrap(b);
}

// ---------------------------------------------------------------------
// for new note or second note
void Note::setpos()
{
  int x,y,w,h,wid;

  if (note==0) {
    x=config.EditPos[0];
    y=config.EditPos[1];
    w=config.EditPos[2];
    h=config.EditPos[3];
  } else {
    QDesktopWidget *d=qApp->desktop();
    QRect s=d->screenGeometry();
    wid=s.width();
    QPoint p=note->pos();
    QSize z=note->size();
    x=p.x();
    y=p.y();
    w=z.width();
    h=z.height();
    x=(wid > w + 2*x) ? wid-w : 0;
  }
  move(x,y);
  resize(w,h);
}

// ---------------------------------------------------------------------
void Note::settext(QString s)
{
  tabs->tabsettext(s);
}

// ---------------------------------------------------------------------
void Note::settitle(QString file, bool mod)
{
  QString f,n,s;

  if (file.isEmpty()) {
    s="Edit";
    if (project.Id.size())
      s="[" + project.Id + "] - " + s;
    setWindowTitle(s);
    return;
  }

  s=cfsname(file);
  if (project.Id.size()) n="[" + project.Id + "] - ";

  if (file == cpath("~" + project.Id + "/" + s))
    f = s;
  else
    f = project.projectname(file);
  setWindowTitle ("[*]" + f + " - " + n + "Edit");
  setWindowModified(mod);
}

// ---------------------------------------------------------------------
void Note::siderefresh()
{
  sideBar->refresh();
}

// ---------------------------------------------------------------------
void Note::tabclose(int index)
{
  tabs->tabclose(index);
  scriptenable();
}
