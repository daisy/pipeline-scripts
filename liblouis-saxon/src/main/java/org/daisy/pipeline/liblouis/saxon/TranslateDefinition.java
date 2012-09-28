/**
 * Copyright (C) 2010 Swiss Library for the Blind, Visually Impaired and Print Disabled
 *
 * This file is part of LiblouisSaxonExtension.
 *
 * LiblouisSaxonExtension is free software: you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

package org.daisy.pipeline.liblouis.saxon;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.liblouis.Liblouis;

public class TranslateDefinition extends ExtensionFunctionDefinition {

	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://liblouis.org/liblouis", "translate");

	private Liblouis liblouis = null;
	
	public void bindLiblouis(Liblouis liblouis) {
		this.liblouis = liblouis;
	}

	public void unbindLiblouis(Liblouis liblouis) {
		this.liblouis = null;
	}
	
	@Override
	public StructuredQName getFunctionQName() {
		return funcname;
	}

	@Override
	public int getMinimumNumberOfArguments() {
		return 2;
	}

	@Override
	public int getMaximumNumberOfArguments() {
		return 2;
	}

	@Override
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING };
	}

	@Override
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}

	@Override
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {

			@SuppressWarnings({ "rawtypes", "unchecked" })
			@Override
			public SequenceIterator call(SequenceIterator[] arguments,
					XPathContext context) throws XPathException {

				StringValue table = (StringValue) arguments[0].next();
				if (null == table)
					return EmptyIterator.getInstance();
				StringValue toTranslate = (StringValue) arguments[1]
						.next();
				if (null == toTranslate)
					return EmptyIterator.getInstance();
				try {
					return SingletonIterator.makeIterator(new StringValue(liblouis
							.translate(table.getStringValue(), toTranslate.getStringValue()))); }
				catch (Exception e) {
					throw new XPathException(e);}
			}

			private static final long serialVersionUID = 1L;
		};
	}

	private static final long serialVersionUID = 1L;
}
