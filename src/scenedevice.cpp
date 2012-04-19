
#include <QApplication>
#include <QGraphicsView>
#include <QGraphicsTextItem>
#include <QFontMetricsF>
#include <QMessageBox>
#include <QKeyEvent>
#include <QGraphicsSceneMouseEvent>

#include <qtbase.h>
#include "devhelpers.hpp"
#include "scenedevice.hpp"


extern "C" {

Rboolean
RSceneDeviceDriver(pDevDesc dev,
		   double width, double height,
		   double ps,
		   RSceneDevice *qdev);

SEXP
qt_qsceneDevice(SEXP width,
		SEXP height,
		SEXP pointsize,
		SEXP family);
// SEXP rscene);

// SEXP 
// qt_qsetScene(SEXP rview, SEXP rscene);

// SEXP
// qt_qsceneView(SEXP x); 

}




typedef Rboolean
(*RSceneDeviceCreateFun)(pDevDesc,
			 double width, double height,
			 double ps,
			 RSceneDevice *qdev);


static GEDevDesc*
createRSceneDevice(double width, double height,
		   double ps,
		   RSceneDevice *qdev,
		   RSceneDeviceCreateFun init_fun);

static
RSceneDevice *startdev(double width,
		       double height,
		       double pointsize,
		       const char *family); 
// GraphicsSceneWithEvents *scene);


static void
do_QTScene(double width,
	   double height,
	   double pointsize,
	   RSceneDevice *qdev);

SEXP
qt_qsceneDevice(SEXP width,
		SEXP height,
		SEXP pointsize,
		SEXP family)
// SEXP rscene)
{
    RSceneDevice *dev = startdev(asReal(width), 
				 asReal(height), 
				 asReal(pointsize), 
				 CHAR(asChar(family)));
    // unwrapSmoke(rscene, QGraphicsScene));
    // return R_NilValue; // or external pointer?
    return wrapSmoke(dev->scene(), QGraphicsScene, true);
}


// SEXP 
// qt_qsetScene(SEXP rview, SEXP rscene)
// {
//     // rview is new smoke-style, rscene is old-style
//     unwrapSmoke(rview, QGraphicsView)->
// 	setScene(unwrapQObject(rscene, QGraphicsScene));
//     return R_NilValue;
// }

// SEXP
// qt_qsceneView(SEXP scene)
// {
//     QGraphicsView *v = new QGraphicsView(unwrapQObject(scene, QGraphicsScene), 0);
//     v->setRenderHints(QPainter::TextAntialiasing);
//     v->setInteractive(true);
//     // v->setDragMode(QGraphicsView::RubberBandDrag);
//     v->setDragMode(QGraphicsView::ScrollHandDrag);
//     return wrapQWidget(v);
// }



static
RSceneDevice *startdev(double width,
		       double height,
		       double pointsize,
		       const char *family)
// GraphicsSceneWithEvents *scene)
{
    GraphicsSceneWithEvents *scene = new GraphicsSceneWithEvents();
    RSceneDevice *dev = new RSceneDevice(width * 72, height * 72, 
					 pointsize, family, scene);
    return dev;
}


static void
do_QTScene(double width,
	   double height,
	   double pointsize,
	   RSceneDevice *qdev)
{
    if (width <= 0 || height <= 0) {
	error("Invalid width or height in do_QTScene: (%g, %g)", width, height);
    }
    createRSceneDevice(width, height, pointsize, 
		       qdev, RSceneDeviceDriver);
    return;
}

RSceneDevice::RSceneDevice(double width, double height,
			   double pointsize, 
			   const char *family,
			   GraphicsSceneWithEvents *scene)
{
    _scene = scene;
    _scene->setItemIndexMethod(QGraphicsScene::NoIndex);
    debug = false;
    force_repaint = false;
    zclip = 0.0;
    zitem = 0.0;
    default_family = QString(family);
    setDeviceNumber(curDevice());
    _scene->setSceneRect(0.0, 0.0, width, height);
    clip_rect = _scene->addRect(scene->sceneRect());
    do_QTScene(width, height, pointsize, this);
}

// RSceneDevice::~RSceneDevice()
// {
//     delete _scene;
//     delete clip_rect;
// }


void RSceneDevice::setClipping(pDevDesc dev)
{
    Rprintf("Clip: %g, %g, %g, %g\n",
	    dev->clipLeft, 
	    dev->clipBottom, 
	    dev->clipRight, 
	    dev->clipTop);
//     clip_rect = 
// 	addRect(QRectF(dev->clipLeft, 
// 		       dev->clipBottom, 
// 		       dev->clipRight - dev->clipLeft, 
// 		       dev->clipTop - dev->clipBottom),
// 		QPen(Qt::NoPen));
//     clip_rect->setZValue(zclip);
//     clip_rect->setFlags(QGraphicsItem::ItemClipsChildrenToShape);
//     zclip += 0.1;
//     zitem = 0.0;
}

void RSceneDevice::addClippedItem(QGraphicsItem *item)
{
    // item->setParentItem(0);
    // item->setParentItem(clip_rect);
    item->setZValue(zitem);
    zitem += 0.1;
}

// typedef struct {
//     /*
//      * Colours
//      *
//      * NOTE:  Alpha transparency included in col & fill
//      */
//     int col;             /* pen colour (lines, text, borders, ...) */
//     int fill;            /* fill colour (for polygons, circles, rects, ...) */
//     double gamma;        /* Gamma correction */
//     /*
//      * Line characteristics
//      */
//     double lwd;          /* Line width (roughly number of pixels) */
//     int lty;             /* Line type (solid, dashed, dotted, ...) */
//     R_GE_lineend lend;   /* Line end */
//     R_GE_linejoin ljoin; /* line join */
//     double lmitre;       /* line mitre */
//     /*
//      * Text characteristics
//      */
//     double cex;          /* Character expansion (font size = fontsize*cex) */
//     double ps;           /* Font size in points */
//     double lineheight;   /* Line height (multiply by font size) */
//     int fontface;        /* Font face (plain, italic, bold, ...) */
//     char fontfamily[201]; /* Font family */
// } R_GE_gcontext;

// device 'callbacks'

void 
RSceneDevice::Circle(double x, double y, double r,
		     R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::Circle\n");
    QPen pen(Qt::NoPen);
    QBrush brush;
    QRectF rect(x - r, y - r, 2 * r, 2 * r);
    int col = gc->col;
    int fill = gc->fill;
    // double gamma = gc->gamma;
    double lwd = gc->lwd;
    int lty = gc->lty;     // FIXME: should be easy to add
    if (col != NA_INTEGER && !R_TRANSPARENT(col)) {
	pen.setStyle(lty2style(lty));
	pen.setColor(r2qColor(col));
	pen.setWidthF(lwd);
    }
    if (fill != NA_INTEGER && !R_TRANSPARENT(fill)) {
	brush.setColor(r2qColor(fill));
	brush.setStyle(Qt::SolidPattern);
    }
    // FIXME: We can either create items separately and add them in
    // addClippedItem() as here, or do addClippedItem(addEllipse(...))
    // which removes and adds (as in the other callbacks currently).
    // The first is probably better, so should fix the others.
    addClippedItem(scene()->addEllipse(rect, pen, brush));
//     QGraphicsEllipseItem *item = new QGraphicsEllipseItem(rect);
//     item->setPen(pen);
//     item->setBrush(brush);
//     addClippedItem(item);
    return;
}

void 
RSceneDevice::Line(double x1, double y1, double x2, double y2,
		   R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::Line\n");
    QPen pen(Qt::NoPen);
    QLineF line(x1, y1, x2, y2);
    int col = gc->col;
    // double gamma = gc->gamma;
    double lwd = gc->lwd;
    int lty = gc->lty;
    if (col != NA_INTEGER && !R_TRANSPARENT(col)) {
	pen.setStyle(lty2style(lty));
	pen.setColor(r2qColor(col));
	pen.setWidthF(lwd);
    }
    addClippedItem(scene()->addLine(line, pen));
    return;
}


void 
RSceneDevice::Polygon(int n, double *x, double *y,
		      R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::Polygon\n");
    QPen pen(Qt::NoPen);
    QBrush brush;
    QPolygonF polygon;
    if (n > 0) {
	for (int i = 0; i < n; i++) {
	    polygon <<  QPointF(x[i], y[i]);
	}
	// FIXME: do we need to explicitly close the polygon?
	polygon <<  QPointF(x[0], y[0]);
	int col = gc->col;
	int fill = gc->fill;
	//double gamma = gc->gamma;
	double lwd = gc->lwd;
	int lty = gc->lty;
	if (col != NA_INTEGER && !R_TRANSPARENT(col)) {
	    pen.setStyle(lty2style(lty));
	    pen.setColor(r2qColor(col));
	    pen.setWidthF(lwd);
	}
	if (fill != NA_INTEGER && !R_TRANSPARENT(fill)) {
	    brush.setColor(r2qColor(fill));
	    brush.setStyle(Qt::SolidPattern);
	}
	addClippedItem(scene()->addPolygon(polygon, pen, brush));
     }
    return;
}


void 
RSceneDevice::Polyline(int n, double *x, double *y,
			R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::Polyline\n");
    QPen pen(Qt::NoPen);
    int col = gc->col;
    // double gamma = gc->gamma;
    double lwd = gc->lwd;
    int lty = gc->lty;
    //     R_GE_lineend lend;   /* Line end */
    //     R_GE_linejoin ljoin; /* line join */
    //     double lmitre;       /* line mitre */
    if (col != NA_INTEGER && !R_TRANSPARENT(col)) {
	pen.setStyle(lty2style(lty));
	pen.setColor(r2qColor(col));
	pen.setWidthF(lwd);
    }
    if (n > 1) {
	for (int i = 1; i < n; i++) {
	    addClippedItem(scene()->addLine(x[i-1], y[i-1], x[i], y[i], pen));
	}
    }
    return;
}


void 
RSceneDevice::Rect(double x0, double y0, double x1, double y1,
		   R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::Rect\n");
    QPen pen(Qt::NoPen);
    QBrush brush;
    QRectF rect(x0, y0, x1 - x0, y1 - y0);
    int col = gc->col;
    int fill = gc->fill;
    //double gamma = gc->gamma;
    double lwd = gc->lwd;
    int lty = gc->lty;
    if (col != NA_INTEGER && !R_TRANSPARENT(col)) {
	pen.setStyle(lty2style(lty));
	pen.setColor(r2qColor(col));
	pen.setWidthF(lwd);
    }
    if (fill != NA_INTEGER && !R_TRANSPARENT(fill)) {
	brush.setColor(r2qColor(fill));
	brush.setStyle(Qt::SolidPattern);
    }
    addClippedItem(scene()->addRect(rect, pen, brush));
    return;
}


void 
RSceneDevice::TextUTF8(double x, double y, char *str,
		       double rot, double hadj,
		       R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::TextUTF8\n");
    int col = gc->col;
    //double gamma = gc->gamma;
    double cex = gc->cex;
    double ps = gc->ps;
    double lineheight = gc->lineheight;
    int fontface = gc->fontface;
    char* fontfamily = gc->fontfamily; // [201] ??
    QString qstr = QString::fromUtf8(str);
    // we have a choice between using QGraphicsTextItem and
    // QGraphicsSimpleTextItem.  We'll use the first because it allows
    // us to make them HTML links later from R
    QGraphicsTextItem 
	*text = scene()->addText(qstr, 
				 r2qFont(fontfamily, fontface, ps, cex, lineheight,
					 defaultFamily()));
    text->setDefaultTextColor(r2qColor(col)); // for QGraphicsTextItem
    // text->setBrush(QBrush(r2qColor(col))); // for QGraphicsSimpleTextItem
    QRectF brect = text->boundingRect();
    text->rotate(-rot);
    text->translate(-hadj * brect.width(), -0.7 * brect.height());
    text->setPos(x, y);
    addClippedItem(text);
    return;
}



void 
RSceneDevice::NewPage(R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::NewPage\n");
    QList<QGraphicsView *> viewlist = scene()->views();
    for (int i = 0; i < viewlist.size(); i++) {
	viewlist[i]->repaint();
    }
    QApplication::processEvents();
    // FIXME: save snapshots if activated?
    scene()->clear();
    zclip = 0.0;
    zitem = 0.0;
    // To account for par("bg")? 
    int fill = gc->fill;
    if (fill != NA_INTEGER && !R_TRANSPARENT(fill)) {
	scene()->setBackgroundBrush(r2qColor(fill));
    } else {
	scene()->setBackgroundBrush(QBrush());
    }
    return;
}

void 
RSceneDevice::ConfirmNewFrame()
{
    QList<QGraphicsView *> viewlist = scene()->views();
    if (viewlist.size() == 0) return; // no view
    else if (viewlist.size() == 1) {
	viewlist[0]->setWindowTitle(QString("Press Enter to see next page"));
	bool old_interactive = viewlist[0]->isInteractive();
	viewlist[0]->setInteractive(true);
	viewlist[0]->activateWindow();
	viewlist[0]->setFocus();
	bool done = false;
	// QKeyEvent *kevent;
	while (!done) {
	    // scene()->resetLastKeyEvent();
	    scene()->setWantKeyboardInput(true);
	    while (scene()->wantKeyboardInput()) {
		// FIXME: To avoid 100% CPU usage, can we portably sleep for a bit here?
		R_CheckUserInterrupt();
		QApplication::processEvents();
	    }
	    // kevent = scene()->lastKeyEvent();
	    if ((scene()->lastKeyType == QEvent::KeyPress) &&
		((scene()->lastKeyKey == Qt::Key_Return) || 
		 (scene()->lastKeyKey == Qt::Key_Enter))) 
		{
		    done = true;
		}
	}
	viewlist[0]->setInteractive(old_interactive);
	viewlist[0]->setWindowTitle(QString("[ACTIVE] QGraphicsScene(View) Device"));
    }
    else {
	// Don't bother with title changes
	QMessageBox msgBox;
	msgBox.setText("Confirm next page.");
	// msgBox.setWindowFlags(Qt::Popup);
	msgBox.exec();
    }
}


bool 
RSceneDevice::LocateOnePoint(double *x, double *y)
{
    QList<QGraphicsView *> viewlist = scene()->views();
    QApplication::processEvents();
    *x = 100;
    *y = 100;
    if (viewlist.size() == 0) return false; // no view
    else if (viewlist.size() == 1) {
	viewlist[0]->setWindowTitle(QString("Click inside the device window"));
	viewlist[0]->activateWindow();
	viewlist[0]->setFocus();
	bool old_interactive = viewlist[0]->isInteractive();
	viewlist[0]->setInteractive(true);
	QGraphicsView::DragMode old_dragmode = viewlist[0]->dragMode();
	viewlist[0]->setDragMode(QGraphicsView::NoDrag);
	Qt::CursorShape old_cursor = viewlist[0]->cursor().shape();
	viewlist[0]->setCursor(Qt::CrossCursor);
	Qt::ContextMenuPolicy old_context = viewlist[0]->contextMenuPolicy();
	viewlist[0]->setContextMenuPolicy(Qt::PreventContextMenu);
	bool done = false, leftbutton = false;
	while (!done) {
	    // scene()->resetLastMouseEvent();
	    scene()->setWantMouseInput(true);
	    while (scene()->wantMouseInput()) {
		// To avoid 100% CPU usage, can we portably sleep for a bit here?
		R_CheckUserInterrupt();
		QApplication::processEvents();
	    }
	    QApplication::processEvents();
	    if (scene()->lastMouseType == QEvent::GraphicsSceneMousePress && 
		scene()->lastMouseButton != Qt::NoButton)
		{
		    done = true;
		    if (scene()->lastMouseButton == Qt::LeftButton) { // else return false
			leftbutton = true;
			*x = (double) scene()->lastMousePos.x();
			*y = (double) scene()->lastMousePos.y();
		    }
		}
	}
	viewlist[0]->setContextMenuPolicy(old_context);
	viewlist[0]->setCursor(old_cursor);
	viewlist[0]->setDragMode(old_dragmode);
	viewlist[0]->setInteractive(old_interactive);
	viewlist[0]->setWindowTitle(QString("[ACTIVE] QGraphicsScene(View) Device"));
	return leftbutton;
    }
    else {
	// Don't do anything.  FIXME: Give feedback to the user?
	// warning()?
	warning("Multiple views open.  Ignoring Locator() request.");
	return false;
    }
    return false; // to keep compiler happy
}



void 
RSceneDevice::Mode(int mode)
{
    if (force_repaint) {
	if (mode == 0) {
	    QList<QGraphicsView *> viewlist = scene()->views();
	    for (int i = 0; i < viewlist.size(); i++) {
		viewlist[i]->repaint();
	    }
	}
	QApplication::processEvents();
    }
    else {
	if (mode == 1) {
	    QApplication::setOverrideCursor(QCursor(Qt::WaitCursor));
	}
	else {
	    QApplication::restoreOverrideCursor();
	}
    }
}


void 
RSceneDevice::Activate()
{
    QList<QGraphicsView *> viewlist = scene()->views();
    for (int i = 0; i < viewlist.size(); i++) {
	viewlist[i]->setWindowTitle(QString("[ACTIVE] QGraphicsScene(View) Device"));
    }
    QApplication::processEvents();
}

void 
RSceneDevice::Deactivate()
{
    QList<QGraphicsView *> viewlist = scene()->views();
    for (int i = 0; i < viewlist.size(); i++) {
	viewlist[i]->setWindowTitle(QString("[inactive] QGraphicsScene(View) Device"));
    }
    QApplication::processEvents();
}

void 
RSceneDevice::Close()
{
    scene()->clear();
    delete scene(); // _scene;
    QApplication::processEvents();
}




// FIXME: doesn't work for some plotmath things at least (e.g. \sum)
void 
RSceneDevice::MetricInfo(int c,
			 R_GE_gcontext *gc,
			 double* ascent, double* descent,
			 double* width)
{
    if (debug) Rprintf("RSceneDevice::MetricInfo\n");
    double cex = gc->cex;
    double ps = gc->ps;
    double lineheight = gc->lineheight;
    int fontface = gc->fontface;
    char* fontfamily = gc->fontfamily;
    bool Unicode = mbcslocale; // && (gc->fontface != 5);
    if (c < 0) { Unicode = TRUE; c = -c; }
    QFontMetricsF fm(r2qFont(fontfamily, fontface, ps, cex, 
			     lineheight, defaultFamily()));
    QChar uc = QChar(c);
    QRectF bb = fm.boundingRect(uc); 
    *ascent = (-bb.top());
    *descent = (bb.bottom());
    *width = bb.width();
    // Rprintf("Metric Info: %g, %g, %g\n", *ascent, *descent, *width);
//     *ascent = (double) (bb.height());
//     *descent = (double) (0.0);
//     *width = (double) fm.width(uc);
    return;
}


double 
RSceneDevice::StrWidthUTF8(char *str,
			   R_GE_gcontext *gc)
{
    if (debug) Rprintf("RSceneDevice::StrWidthUTF8\n");
    double cex = gc->cex;
    double ps = gc->ps;
    double lineheight = gc->lineheight;
    int fontface = gc->fontface;
    char* fontfamily = gc->fontfamily;
    QString qstr = QString::fromUtf8(str);
    QGraphicsSimpleTextItem *text = new QGraphicsSimpleTextItem(str, 0);
    text->setFont(r2qFont(fontfamily, fontface, 
			  ps, cex, lineheight,
			  defaultFamily()));
    QRectF brect = text->boundingRect();
    delete text;
    return brect.width();
}


#define asSceneDevice(x) ((RSceneDevice *) x->deviceSpecific)
// alternative: use qobject_cast ?



static void 
QT_Circle(double x, double y, double r,
	  R_GE_gcontext *gc, pDevDesc dev)
{
    return asSceneDevice(dev)->Circle(x, y, r, gc);
}

static void 
QT_Line(double x1, double y1, double x2, double y2,
	R_GE_gcontext *gc,
	pDevDesc dev)
{
    return asSceneDevice(dev)->Line(x1, y1, x2, y2, gc);
}

static void 
QT_Polygon(int n, double *x, double *y,
	   R_GE_gcontext *gc,
	   pDevDesc dev)
{
    return asSceneDevice(dev)->Polygon(n, x, y, gc);
}

static void 
QT_Polyline(int n, double *x, double *y,
	    R_GE_gcontext *gc,
	    pDevDesc dev)
{
    return asSceneDevice(dev)->Polyline(n, x, y, gc);
}

static void 
QT_Rect(double x0, double y0, double x1, double y1,
	R_GE_gcontext *gc,
	pDevDesc dev)
{
    return asSceneDevice(dev)->Rect(x0, y0, x1, y1, gc);
}

static void 
QT_TextUTF8(double x, double y, char *str,
	    double rot, double hadj,
	    R_GE_gcontext *gc,
	    pDevDesc dev)
{
    return asSceneDevice(dev)->TextUTF8(x, y, str, rot, hadj, gc);
}

static void 
QT_NewPage(R_GE_gcontext *gc,
	   pDevDesc dev)
{
    return asSceneDevice(dev)->NewPage(gc);
}

static void 
QT_MetricInfo(int c, R_GE_gcontext *gc,
	      double* ascent, double* descent,
	      double* width,
	      pDevDesc dev)
{
    return asSceneDevice(dev)->MetricInfo(c, gc, ascent, descent, width);
}

static double 
QT_StrWidthUTF8(char *str, R_GE_gcontext *gc,
		pDevDesc dev)
{
    return asSceneDevice(dev)->StrWidthUTF8(str, gc);
}


static void QT_Close(pDevDesc dev)
{
    asSceneDevice(dev)->Close();
    delete asSceneDevice(dev); // Need this?
}


static void QT_Activate(pDevDesc dev)
{
    return asSceneDevice(dev)->Activate();
}

static void QT_Deactivate(pDevDesc dev)
{
    return asSceneDevice(dev)->Deactivate();
}

static void QT_Clip(double left, 
		    double right, 
		    double bottom, 
		    double top,
		    pDevDesc dev)
{
    dev->clipLeft   = left;
    dev->clipRight  = right;
    dev->clipBottom = bottom;
    dev->clipTop    = top;
    // asSceneDevice(dev)->setClipping(dev);
    return;
}


static void QT_Mode(int mode, pDevDesc dev)
{
    return asSceneDevice(dev)->Mode(mode);
}


static Rboolean QT_Locator(double *x, double *y, pDevDesc dev)
{
    if (asSceneDevice(dev)->LocateOnePoint(x, y))
	return TRUE; 
    else return FALSE;
}

static Rboolean QT_NewFrameConfirm(pDevDesc dev)
{
    // Rprintf("Confirm new page\n");
    asSceneDevice(dev)->ConfirmNewFrame();
    return TRUE; 
}



// // FIXME: not OK
// static void QT_Size(double *left, double *right,
// 		    double *bottom, double *top,
// 		    pDevDesc dev)
// {
//     // FIXME FIXME FIXME : should I do this here?
//     dev->left = 0;
//     dev->right = asSceneDevice(dev)->scene()->width();
//     dev->bottom = asSceneDevice(dev)->scene()->height();
//     dev->top = 0;
//     // Rprintf("Someone called QT_Size\n");
//     *left = 0.0;
//     *right = asSceneDevice(dev)->scene()->width();
//     *bottom = asSceneDevice(dev)->scene()->height();
//     *top = 0.0;
//     return;
// }



/* Device driver entry point */
Rboolean
RSceneDeviceDriver(pDevDesc dev,
		   double width, double height,
		   double ps,
		   RSceneDevice *qdev)
{
    // store a pointer to the device object (in Qt)
    dev->deviceSpecific = (void *) qdev;

    // pointsize?

    /*
     * Initial graphical settings
     */
    dev->startfont = 1;
    dev->startps = ps;
    dev->startcol = R_RGB(0, 0, 0);
    dev->startfill = R_TRANWHITE;
    dev->startlty = LTY_SOLID;
    dev->startgamma = 1;
    /*
     * Device physical characteristics
     */
    double DPI = 72;

    dev->left   = dev->clipLeft   = 0;
    dev->right  = dev->clipRight  = qdev->scene()->width();
    dev->bottom = dev->clipBottom = qdev->scene()->height();
    dev->top    = dev->clipTop    = 0;
    dev->cra[0] = 0.9 * ps;
    dev->cra[1] = 1.2 * ps;
    dev->xCharOffset = 0.4900;
    dev->yCharOffset = 0.3333;
    dev->yLineBias = 0.1;
    dev->ipr[0] = 1.0 / DPI;
    dev->ipr[1] = 1.0 / DPI;
    /*
     * Device capabilities
     */
    dev->canClip = FALSE; // FIXME. can clip, but then selection becomes weird
    dev->canHAdj = 2;
    dev->canChangeGamma = FALSE;
    dev->displayListOn = TRUE;

    dev->hasTextUTF8 = TRUE;
    dev->textUTF8 = (void (*)()) QT_TextUTF8;
    dev->strWidthUTF8 = (double (*)()) QT_StrWidthUTF8;
    dev->wantSymbolUTF8 = TRUE;
    dev->useRotatedTextInContour = TRUE;

    dev->haveTransparency = 2;
    dev->haveTransparentBg = 2; // FIXME. Do we really? Check.
    dev->haveRaster = 1;
    dev->haveCapture = 1;
    dev->haveLocator = 2;

    /*
     * Mouse events
     */
//     dev->canGenMouseDown = TRUE;
//     dev->canGenMouseMove = TRUE;
//     dev->canGenMouseUp = TRUE; 
//     dev->canGenKeybd = TRUE;

    // gettingEvent; This is set while getGraphicsEvent is actively
    // looking for events




    /*
     * Device functions
     */
    dev->activate =    (void (*)()) QT_Activate;
    dev->circle =      (void (*)()) QT_Circle;
    dev->clip =        (void (*)()) QT_Clip;
    dev->close =       (void (*)()) QT_Close;
    dev->deactivate =  (void (*)()) QT_Deactivate;
    dev->locator = (Rboolean (*)()) QT_Locator;
    dev->line =        (void (*)()) QT_Line;
    dev->metricInfo =  (void (*)()) QT_MetricInfo;
    dev->mode =        (void (*)()) QT_Mode;
    dev->newPage =     (void (*)()) QT_NewPage;
    dev->polygon =     (void (*)()) QT_Polygon;
    dev->polyline =    (void (*)()) QT_Polyline;
    dev->rect =        (void (*)()) QT_Rect;
    dev->size =        NULL; // (void (*)()) QT_Size;
    // dev->strWidth =  (double (*)()) QT_StrWidth;
    // dev->text =        (void (*)()) QT_Text;
    // dev->onexit =      (void (*)()) QT_OnExit; NULL is OK
    // dev->getEvent = SEXP (*getEvent)(SEXP, const char *);
    dev->newFrameConfirm = (Rboolean (*)()) QT_NewFrameConfirm;
    // dev->
    return TRUE;
}



static GEDevDesc*
createRSceneDevice(double width, double height,
		   double ps,
		   RSceneDevice *qdev,
		   RSceneDeviceCreateFun init_fun)
{
    pGEDevDesc gdd;
    // pDevDesc dev;

    R_GE_checkVersionOrDie(R_GE_version);
    R_CheckDeviceAvailable();
    BEGIN_SUSPEND_INTERRUPTS {
	pDevDesc dev;
	/* Allocate and initialize the device driver data */
	if (!(dev = (pDevDesc) calloc(1, sizeof(DevDesc))))
	    return 0; /* or error() */
	/* set up device driver or free 'dev' and error() */
	if (!init_fun(dev, width, height, ps, qdev)) {
	    free(dev); // delete qdev; // ??
	    error("unable to start device");
	}
	gdd = GEcreateDevDesc(dev);
	gdd->displayList = R_NilValue;
	// gdd->savedSnapshot = R_NilValue;
	GEaddDevice2(gdd, "QTScene");
    } END_SUSPEND_INTERRUPTS;

    return(gdd);
}





