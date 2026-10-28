/* exported splitSeries */

/*
 * Splits a recurring event into the part before one of its occurrences and the
 * part from that occurrence on, the way RFC 5545 suggests for changing "this and
 * future" occurrences: the original series keeps its UID and ends before the
 * split, and a new series with a new UID starts at it.
 *
 * Loaded into the experiment's scope with `Services.scriptloader.loadSubScript()`;
 * expects `cal` from calUtils.sys.mjs in that scope.
 */

/**
 * Split the recurring event `parentItem` at the occurrence whose RECURRENCE-ID
 * is `splitId`; returns `{ past, future }`, two new mutable events, or null when
 * `splitId` is the first occurrence, since then nothing comes before it.
 */
function splitSeries(parentItem, splitId) {
  // the first occurrence's RECURRENCE-ID is always the series' DTSTART
  if (splitId.compare(parentItem.startDate) <= 0) {
    return null;
  }

  const past = parentItem.clone();
  const future = parentItem.clone();

  // detach the recurrence before moving the future series' start: the
  // startDate setter would otherwise shift every EXDATE, RDATE, UNTIL and
  // exception by the same amount (CalRecurrenceInfo.onStartDateChange())
  const futureInfo = future.recurrenceInfo;
  future.recurrenceInfo = null;
  const duration = parentItem.endDate.subtractDate(parentItem.startDate);
  const start = splitId.getInTimezone(parentItem.startDate.timezone);
  const end = start.clone();
  end.addDuration(duration);
  future.startDate = start;
  future.endDate = end;
  future.id = cal.getUUID();
  future.recurrenceInfo = futureInfo;
  futureInfo.item = future;
  futureInfo.onIdChange(future.id);

  splitRecurrenceItems(past.recurrenceInfo, futureInfo, parentItem.startDate, splitId);

  // exceptions are keyed by their original slot, so a moved occurrence goes
  // with the side its original slot falls on
  for (const id of past.recurrenceInfo.getExceptionIds()) {
    if (id.compare(splitId) >= 0) {
      past.recurrenceInfo.removeExceptionFor(id);
    }
  }
  for (const id of futureInfo.getExceptionIds()) {
    if (id.compare(splitId) < 0) {
      futureInfo.removeExceptionFor(id);
    }
  }

  return { past, future };
}

/**
 * Cut the RRULEs, RDATEs and EXDATEs of two clones of the same recurrence
 * info, so `pastInfo` keeps what comes before `splitId` and `futureInfo` what
 * comes from it on.
 */
function splitRecurrenceItems(pastInfo, futureInfo, seriesStart, splitId) {
  // both clones list their items in the original order, so the same index
  // refers to the same RRULE or date in both; walk backwards so deleting an
  // item doesn't shift the ones still to visit
  const count = pastInfo.countRecurrenceItems();
  for (let i = count - 1; i >= 0; i--) {
    const pastItem = pastInfo.getRecurrenceItemAt(i);
    const futureItem = futureInfo.getRecurrenceItemAt(i);

    // RDATE or EXDATE: a single date, kept on the side it falls on
    if ("date" in pastItem) {
      if (pastItem.date.compare(splitId) >= 0) {
        pastInfo.deleteRecurrenceItemAt(i);
      } else {
        futureInfo.deleteRecurrenceItemAt(i);
      }
      continue;
    }

    // EXRULE: applies the same way to both sides
    if (pastItem.isNegative) {
      continue;
    }

    // RRULE; `getOccurrences()` returns the slots before its range end
    const before = pastItem.getOccurrences(seriesStart, seriesStart, splitId, 0).length;
    if (before == 0) {
      pastInfo.deleteRecurrenceItemAt(i);
    } else if (pastItem.isByCount) {
      pastItem.count = before;
    } else if (!pastItem.untilDate || pastItem.untilDate.compare(splitId) >= 0) {
      pastItem.untilDate = dayOrSecondBefore(splitId);
    }

    if (futureItem.isByCount) {
      const remaining = futureItem.count - before;
      if (remaining > 0) {
        futureItem.count = remaining;
      } else {
        futureInfo.deleteRecurrenceItemAt(i);
      }
    } else if (futureItem.untilDate && futureItem.untilDate.compare(splitId) < 0) {
      futureInfo.deleteRecurrenceItemAt(i);
    }
  }
}

/**
 * Return the last moment before `date` that an inclusive UNTIL can name: the
 * day before for all-day events, the second before otherwise.
 */
function dayOrSecondBefore(date) {
  const until = date.isDate ? date.clone() : date.getInTimezone(cal.dtz.UTC);
  until.addDuration(cal.createDuration(date.isDate ? "-P1D" : "-PT1S"));
  return until;
}
