;;;========================================================================
;;; BOUNDARY OFFSET - Creates an outer boundary polyline with offset
;;;========================================================================
;;; Description: Creates an outer boundary polyline around selected objects
;;;              based on their shape with a specified offset distance.
;;;
;;; Modified Version: Automatically generates outer boundary without 
;;;                   internal point prompt. Uses automatic offset direction
;;;                   calculation to create outer boundary.
;;;========================================================================

(defun C:BOUNDARYOFFSET (/ ss cnt idx ent ent-data ent-type pt-list min-x min-y max-x max-y 
                           inner-boundary outer-boundary offset-dist 
                           center-pt offset-pt x-val y-val ent-pointer radius)
  
  ;;;--------------------------------------------------------------------
  ;;; STEP 1: Prompt user to select objects
  ;;;--------------------------------------------------------------------
  ;; Ask user to select objects that will be used to create the boundary
  (princ "\nSelect objects to create boundary around: ")
  (setq ss (ssget))
  
  ;; Check if user selected any objects
  (if ss
    (progn
      
      ;;;--------------------------------------------------------------------
      ;;; STEP 2: Set the offset distance
      ;;;--------------------------------------------------------------------
      ;; Define the offset distance for the outer boundary (retained as specified)
      (setq offset-dist 0.6)
      (princ (strcat "\nUsing offset distance: " (rtos offset-dist 2 2)))
      
      ;;;--------------------------------------------------------------------
      ;;; STEP 3: Get internal point from user (REMOVED IN MODIFICATION)
      ;;;--------------------------------------------------------------------
      ;; ORIGINAL CODE (now removed): Required user to pick internal point
      ;; (setq pt3d (getpoint "\nPick a point INSIDE the objects: "))
      ;;
      ;; MODIFICATION: Internal point is no longer required. The boundary
      ;; is created directly from the selected objects without needing
      ;; an internal point for the BOUNDARY command.
      ;; The offset direction is calculated automatically based on the
      ;; geometry of the selected objects.
      
      ;;;--------------------------------------------------------------------
      ;;; STEP 4: Calculate bounding box for automatic point calculation
      ;;;--------------------------------------------------------------------
      ;; Calculate the bounding box of all selected objects to determine
      ;; an automatic internal point for the boundary creation
      (princ "\nAnalyzing selected objects...")
      
      ;; Initialize min/max values with nil for proper first-point handling
      (setq min-x nil min-y nil max-x nil max-y nil)
      (setq cnt (sslength ss))
      (setq idx 0)
      
      ;; Loop through all selected objects to find bounding box
      (while (< idx cnt)
        (setq ent (ssname ss idx))
        (setq ent-data (entget ent))
        (setq ent-type (cdr (assoc 0 ent-data)))
        
        ;; Extract coordinate points based on entity type
        ;; Handle LINE entities
        (if (= ent-type "LINE")
          (progn
            (setq pt-list (list (cdr (assoc 10 ent-data)) 
                               (cdr (assoc 11 ent-data))))
            (foreach pt pt-list
              (setq x-val (car pt) y-val (cadr pt))
              (if (or (not min-x) (< x-val min-x)) (setq min-x x-val))
              (if (or (not max-x) (> x-val max-x)) (setq max-x x-val))
              (if (or (not min-y) (< y-val min-y)) (setq min-y y-val))
              (if (or (not max-y) (> y-val max-y)) (setq max-y y-val))
            )
          )
        )
        
        ;; Handle CIRCLE entities
        (if (= ent-type "CIRCLE")
          (progn
            (setq center-pt (cdr (assoc 10 ent-data)))
            (setq radius (cdr (assoc 40 ent-data)))
            (setq x-val (car center-pt) y-val (cadr center-pt))
            (if (or (not min-x) (< (- x-val radius) min-x)) (setq min-x (- x-val radius)))
            (if (or (not max-x) (> (+ x-val radius) max-x)) (setq max-x (+ x-val radius)))
            (if (or (not min-y) (< (- y-val radius) min-y)) (setq min-y (- y-val radius)))
            (if (or (not max-y) (> (+ y-val radius) max-y)) (setq max-y (+ y-val radius)))
          )
        )
        
        ;; Handle POLYLINE/LWPOLYLINE entities - get all vertices
        (if (or (= ent-type "POLYLINE") (= ent-type "LWPOLYLINE"))
          (progn
            ;; For LWPOLYLINE, vertices are in the main entity data
            (if (= ent-type "LWPOLYLINE")
              (progn
                (foreach pair ent-data
                  (if (= (car pair) 10)
                    (progn
                      (setq x-val (cadr pair) y-val (caddr pair))
                      (if (or (not min-x) (< x-val min-x)) (setq min-x x-val))
                      (if (or (not max-x) (> x-val max-x)) (setq max-x x-val))
                      (if (or (not min-y) (< y-val min-y)) (setq min-y y-val))
                      (if (or (not max-y) (> y-val max-y)) (setq max-y y-val))
                    )
                  )
                )
              )
              ;; For old-style POLYLINE, traverse vertex sub-entities
              (progn
                (setq ent-pointer ent)
                (while (setq ent-pointer (entnext ent-pointer))
                  (setq ent-data (entget ent-pointer))
                  (setq ent-type (cdr (assoc 0 ent-data)))
                  (if (= ent-type "VERTEX")
                    (progn
                      (setq pt-list (cdr (assoc 10 ent-data)))
                      (setq x-val (car pt-list) y-val (cadr pt-list))
                      (if (or (not min-x) (< x-val min-x)) (setq min-x x-val))
                      (if (or (not max-x) (> x-val max-x)) (setq max-x x-val))
                      (if (or (not min-y) (< y-val min-y)) (setq min-y y-val))
                      (if (or (not max-y) (> y-val max-y)) (setq max-y y-val))
                    )
                    ;; Break when we reach SEQEND
                    (if (= ent-type "SEQEND")
                      (setq ent-pointer nil)
                    )
                  )
                )
              )
            )
          )
        )
        
        ;; Handle ARC entities
        (if (= ent-type "ARC")
          (progn
            (setq center-pt (cdr (assoc 10 ent-data)))
            (setq radius (cdr (assoc 40 ent-data)))
            (setq x-val (car center-pt) y-val (cadr center-pt))
            (if (or (not min-x) (< (- x-val radius) min-x)) (setq min-x (- x-val radius)))
            (if (or (not max-x) (> (+ x-val radius) max-x)) (setq max-x (+ x-val radius)))
            (if (or (not min-y) (< (- y-val radius) min-y)) (setq min-y (- y-val radius)))
            (if (or (not max-y) (> (+ y-val radius) max-y)) (setq max-y (+ y-val radius)))
          )
        )
        
        (setq idx (1+ idx))
      )
      
      ;; Calculate center point of bounding box (used for boundary creation)
      (setq center-pt (list (/ (+ min-x max-x) 2.0) 
                            (/ (+ min-y max-y) 2.0) 
                            0.0))
      
      (princ (strcat "\nCalculated center point: " 
                    (rtos (car center-pt) 2 2) "," 
                    (rtos (cadr center-pt) 2 2)))
      
      ;;;--------------------------------------------------------------------
      ;;; STEP 5: Create inner boundary polyline from selected objects
      ;;;--------------------------------------------------------------------
      ;; Create a boundary polyline that encompasses the selected objects
      ;; This creates the inner boundary using the calculated center point
      (princ "\nCreating inner boundary from selected objects...")
      
      ;; Use the -BOUNDARY command (command-line version) with calculated point
      ;; The command creates a polyline boundary without user interaction
      ;; by using the calculated center point of the bounding box
      (command "._-BOUNDARY" center-pt "")
      
      ;; Get the last created entity (the inner boundary polyline)
      (setq inner-boundary (entlast))
      
      (if inner-boundary
        (progn
          
          ;;;--------------------------------------------------------------------
          ;;; STEP 6: Create outer boundary using OFFSET command
          ;;;--------------------------------------------------------------------
          ;; Offset the inner boundary outward by the specified offset distance
          ;; This creates the outer boundary polyline at 0.6 units from the inner
          (princ "\nCreating outer boundary with offset...")
          
          ;; Calculate an offset point outside the inner boundary
          ;; Use a point that is beyond the maximum extent of the bounding box
          (setq offset-pt (list (+ max-x offset-dist 1.0) 
                                (+ max-y offset-dist 1.0) 
                                0.0))
          
          ;; Use the OFFSET command to create the outer boundary
          ;; Parameters: offset distance (0.6), source object (inner boundary),
          ;;            offset point (outside the boundary), and empty string to end
          ;; The offset-pt determines the direction (outward)
          (command "._OFFSET" offset-dist inner-boundary offset-pt "")
          
          ;; Get the newly created offset polyline (outer boundary)
          ;; This should be the last entity created in the drawing
          (setq outer-boundary (entlast))
          
          ;;;--------------------------------------------------------------------
          ;;; STEP 7: Delete the inner boundary polyline
          ;;;--------------------------------------------------------------------
          ;; Remove the inner boundary polyline, keeping only the outer boundary
          ;; This ensures only the final offset boundary remains in the drawing
          (princ "\nDeleting inner boundary...")
          (if (and inner-boundary 
                   outer-boundary
                   (not (equal inner-boundary outer-boundary)))
            (progn
              (entdel inner-boundary)
              (princ "\nInner boundary deleted successfully.")
            )
            ;; If the inner and outer boundaries are the same, something went wrong
            (princ "\nWarning: Inner boundary not deleted (may be same as outer).")
          )
          
          ;;;--------------------------------------------------------------------
          ;;; STEP 8: Display completion message
          ;;;--------------------------------------------------------------------
          (princ "\n========================================")
          (princ "\nOuter boundary polyline created successfully!")
          (princ (strcat "\nOffset distance: " (rtos offset-dist 2 2) " units"))
          (princ "\n========================================")
        )
        ;; If inner boundary creation failed
        (progn
          (princ "\n========================================")
          (princ "\nError: Could not create inner boundary.")
          (princ "\nPlease check that selected objects form a closed boundary.")
          (princ "\n========================================")
        )
      )
    )
    ;; If no objects were selected
    (progn
      (princ "\n========================================")
      (princ "\nNo objects selected. Command cancelled.")
      (princ "\n========================================")
    )
  )
  
  ;; Return to command prompt cleanly without printing "nil"
  (princ)
)

;;;========================================================================
;;; End of BOUNDARY OFFSET command
;;;========================================================================
